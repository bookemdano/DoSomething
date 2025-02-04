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
            MoodDays.append(MoodDay(Date: date))
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
        var moods = MoodDays.first(where: {$0.Date == date})?.Moods
        if (moods == nil){
            moods = [:]
        }
        if (status == .NA) {
            MoodItems.forEach { item in
                if (!moods!.contains(where: {$0.key == item.id})) {
                    moods![item.id] = .NA
                }
            }
        }
        return moods!.filter({$0.value == status}).map({GetItem(id: $0.key)}).sorted(by: {$0.Name < $1.Name})
    }
    func GetItem(id: UUID) -> MoodItem{
        return MoodItems.first(where: {$0.id == id}) ?? MoodItem(Name: "Missing")
    }
    mutating func NewMoodItem(name: String, date: Date)
    {
        MoodItems.append(MoodItem(Name: name))
    }
    mutating func Move(date: Date, moodItem: MoodItem, moveFrom: MoodStatusEnum)
    {
        if (!MoodDays.contains(where: {$0.Date == date})) {
            MoodDays.append(MoodDay(Date: date))
        }
        let index = MoodDays.firstIndex(where: {$0.Date == date})!
        var moveTo: MoodStatusEnum = .NA
        if (moveFrom == .Up) { moveTo = .Down }
        else if (moveFrom == .NA) { moveTo = .Up }
        else { moveTo = .NA }
        
        if (moveFrom != .NA) {
            MoodDays[index].Moods.removeValue(forKey: moodItem.id)
        }
        if (moveTo != .NA) {
            MoodDays[index].Moods[moodItem.id] = moveTo
        }
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
    var Moods: [UUID: MoodStatusEnum] = [:]
  
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
