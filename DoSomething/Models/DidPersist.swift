//
//  DidPersist.swift
//  MacLab
//
//  Created by Daniel Francis on 1/9/25.
//

import Foundation

struct DidPersist {
    static let _iop = IOPAws(app: "ToDone")
    static func ChangeOwner(owner: String){
        UserDefaults.standard.set(owner, forKey: "Owner")
    }
    static func GetOwner() -> String{
        return UserDefaults.standard.string(forKey: "Owner") ?? "Dan"
    }
    static func JsonName() -> String{
        let rv = "dids\(GetOwner()).json"
        return rv
    }
    
    static func Read() async -> [Did]{
        
        let content = await _iop.Read(dir: "Data", file: JsonName())
        if (content.isEmpty){
            return DidList().Dids
        }
        
        let jsonString = content
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                var didList = try JSONDecoder().decode(DidList.self, from: jsonData)
                return didList.Dids.sorted()
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        return DidList().Dids
    }
    static func SaveSync(didList: DidList)
    {
        Task
        {
            await SaveAsync(didList: didList)
        }
    }
    static func SaveAsync(didList: DidList) async
    {
        do {
            let jsonData = try JSONEncoder().encode(didList)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                await _iop.Write(dir: "Data", file: JsonName(), content: jsonString)
            }
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
    static func UpdateDid(id: UUID, name: String, points: Int) async
    {
        Task{
            var dids = await Read()

            let index = dids.firstIndex(where: { $0.id == id})
            dids[index!].Name = name
            dids[index!].Points = points
            let didList = DidList(Dids: dids)
            await SaveAsync(didList: didList)
        }
    }
    
}
