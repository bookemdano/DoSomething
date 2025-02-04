//
//  DidPersist.swift
//  MacLab
//
//  Created by Daniel Francis on 1/9/25.
//

import Foundation

struct DidPersist {
    static let _iop = IOPAws(app: "ToDone")

    static func JsonName() -> String{
        let rv = "dids\(IOPAws.GetOwner()).json"
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
    static func RemoveDid(id: UUID) async
    {
        var dids = await Read()
        dids.removeAll(where: { $0.id == id})
        let didList = DidList(Dids: dids)
        await SaveAsync(didList: didList)
    }
    static func UpdateDid(id: UUID, name: String, points: Int, oneTime: Bool, retired: Bool, notes: String) async
    {
        Task{
            var dids = await Read()

            let index = dids.firstIndex(where: { $0.id == id})
            if (index == nil)
            {
                var did: Did = Did(name: name)
                did.Points = points
                did.OneTime = oneTime
                did.Retired = retired
                did.Notes = notes
                dids.append(did)
            }
            else
            {
                dids[index!].Name = name
                dids[index!].Points = points
                dids[index!].Retired = retired
                dids[index!].OneTime = oneTime
                dids[index!].Notes = notes
            }

            let didList = DidList(Dids: dids)
            await SaveAsync(didList: didList)
        }
    }
    
}
