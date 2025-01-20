//
//  DidList.swift
//  MacLab
//
//  Created by Daniel Francis on 1/9/25.
//

import Foundation


struct DidList : Codable {
    var Dids: [Did] = []
    enum CodingKeys: String, CodingKey {
        case Dids
    }

    public mutating func Add(name: String)
    {
        if (name.isEmpty){
            return
        }
        Dids.append(Did(name: name))
    }
    public mutating func Delete(name: String)
    {
        Dids.removeAll(where: { $0.Name == name})
    }
    public func DonePoints(date: Date) -> Int
    {
        return GetDids(date: date).reduce(0){ $0 + $1.GetPoints()}
    }
    public mutating func Done(did: Did, date: Date)
    {
        let index = Dids.firstIndex(where: { $0.id == did.id})
        Dids[index!].SetDone(date: date)
    }
    
    public mutating func UnDone(did: Did, date: Date)
    {
        let index = Dids.firstIndex(where: { $0.id == did.id})
        Dids[index!].SetUnDone(date: date)
    }
    public func GetDids(date: Date) -> [Did] {
        return Dids.filter { $0.DoneOnDate(date: date) == true}
    }
    public func GetDidnts(date: Date) -> [Did] {
        return Dids.filter { $0.DoneOnDate(date: date) == false && $0.IsAvailable()}
    }
    public func GetGroups() -> [String: [Did]] {
        var rv = [String: [Did]]()
        rv["Active"] = []
        rv["OneTime"] = []
        rv["Retired"] = []
       
        Dids.forEach {
            if ($0.IsAvailable()) {
                rv["Active"]?.append($0)
            } else if ($0.OneTime == true) {
                rv["OneTime"]?.append($0)
            } else {
                rv["Retired"]?.append($0)
            }
        }
        return rv
    }
}
