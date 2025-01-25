//
//  MoodItem.swift
//  DoSomething
//
//  Created by Daniel Francis on 1/24/25.
//

import Foundation

struct MoodSet : Codable
{
    var MoodDays: [MoodDay]
    var MoodItems: [MoodItem]
    enum CodingKeys: String, CodingKey {
        case MoodDays
        case MoodItems
    }
    mutating func Refresh(other: MoodSet, date: Date){
        MoodDays.removeAll(keepingCapacity: false)
        MoodDays.append(contentsOf: other.MoodDays)
        MoodItems.removeAll(keepingCapacity: false)
        MoodItems.append(contentsOf: other.MoodItems)
        
        if (!MoodDays.contains(where: {$0.Date == date})) {
            var moods = [MoodStatusEnum: [MoodItem]]()
            moods[.NA] = []
            MoodItems.forEach { moods[.NA]!.append($0) }
            moods[.Up] = []
            moods[.Down] = []
            MoodDays.append(MoodDay(Date: date, Moods: moods))
        }
    }
    static func GetDefault() -> MoodSet
    {
        var moodItems:[MoodItem] = []
        moodItems.append(MoodItem(Name: "Social Media"))
        moodItems.append(MoodItem(Name: "Work"))
        moodItems.append(MoodItem(Name: "Family"))
        moodItems.append(MoodItem(Name: "Kids"))
        return MoodSet(MoodDays: [], MoodItems: moodItems)
    }
    
    func GetItems(date: Date, status: MoodStatusEnum) -> [MoodItem]
    {
        MoodDays.first(where: {$0.Date == date})?.Moods[status] ?? []
    }
    mutating func Move(date: Date, moodItem: MoodItem, moveFrom: MoodStatusEnum)
    {
        var index = MoodDays.firstIndex(where: {$0.Date == date})!
        MoodDays[index].Moods[moveFrom]!.removeAll(where: {$0.id == moodItem.id})
        var moveTo: MoodStatusEnum = .NA
  
        if (moveFrom == .Up) { moveTo = .Down }
        else if (moveFrom == .NA) { moveTo = .Up }
        else { moveTo = .NA }
        
        MoodDays[index].Moods[moveFrom]!.removeAll(where: {$0.id == moodItem.id})
        MoodDays[index].Moods[moveTo]!.append(moodItem)
    
        //var index = MoodDays.firstIndex(where: {$0.Date == date})
    }
}
enum MoodStatusEnum : String, Codable{
    case Up
    case NA
    case Down
}
struct MoodDay : Codable
{

    var Date: Date
    var Moods: [MoodStatusEnum: [MoodItem]]
  
    enum CodingKeys: String, CodingKey {
        case Date
        case Moods
    }
}

struct MoodItem : Codable, Hashable, Identifiable, Comparable
{
    static func < (lhs: MoodItem, rhs: MoodItem) -> Bool {
        return lhs.Name < rhs.Name
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case Name
    }

    var id = UUID() // Automatically generate a unique identifier
    var Name: String
}
struct MoodPersist {
    static let _iop = IOPAws(app: "ToDone")

    static func JsonName() -> String{
        let rv = "moods\(IOPAws.GetOwner()).json"
        return rv
    }
    
    static func Read() async -> MoodSet{
        
        let content = await _iop.Read(dir: "Data", file: JsonName())
        if (content.isEmpty){
            return MoodSet.GetDefault()
        }
        
        let jsonString = content
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                var rv = try JSONDecoder().decode(MoodSet.self, from: jsonData)
                return rv
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        return MoodSet.GetDefault()
    }
    static func SaveSync(moodSet: MoodSet)
    {
        Task
        {
            await SaveAsync(moodSet: moodSet)
        }
    }
    static func SaveAsync(moodSet: MoodSet) async
    {
        do {
            let jsonData = try JSONEncoder().encode(moodSet)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                await _iop.Write(dir: "Data", file: JsonName(), content: jsonString)
            }
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
}
