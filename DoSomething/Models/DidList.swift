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
    public func GetDidnts(date: Date, cat: String) -> [Did] {
        return Dids.filter { $0.DoneOnDate(date: date) == false && $0.IsAvailable() && (cat == "All" || $0.GetCategory() == cat)}
    }
    public func GetCategories() -> [String] {
        var rv = [String]()
        rv.append("All")
        Dids.forEach {
            if ($0.IsAvailable()) {
                let cat = $0.GetCategory()
                if (!rv.contains(cat)) {
                    rv.append(cat)
                }
            }
        }
        return rv
    }
    public func GetGroups(includeDone: Bool) -> [String: [Did]] {
        var rv = [String: [Did]]()
        if (includeDone){
            rv["[OneTime]"] = []
            rv["[Retired]"] = []
        }
       
        Dids.forEach {
   
            if ($0.Retired == true) {
                if (includeDone) {
                    rv["[Retired]"]?.append($0)
                }
            } else if ($0.OneTime == true) {
                if (includeDone) {
                    rv["[OneTime]"]?.append($0)
                }
            }
            else {
                let cat = $0.GetCategory()
                if (!rv.keys.contains(cat)) {
                    rv[cat] = []
                }
                rv[cat]?.append($0)
            }
        }
        return rv
    }
}
