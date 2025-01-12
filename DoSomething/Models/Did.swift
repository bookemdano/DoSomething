//
//  Did.swift
//  MacLab
//
//  Created by Daniel Francis on 1/6/25.
//

import Foundation
// TODO every other day streaks or weekday streaks
// TODO Mark items as "non-current" so only show up in maint
// TODO Faster streak check
struct Did : Codable, Hashable, Identifiable, Comparable
{
    static func < (lhs: Did, rhs: Did) -> Bool {
        return lhs.Name < rhs.Name
    }
    
    init(name: String) {
        Name = name
    }
    func LastDoneString() -> String {
        let date = Did.parseDate(History.sorted(by: <).last)
        if (date == nil)
        {
            return "Never"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"

        return formatter.string(from: date!)
    }

    static func parseDate(_ dateString: String?) -> Date? {
        if (dateString == nil) {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let date = formatter.date(from: dateString!) {
            return date
        }
        return nil
    }
    func DoneOnDate(date: Date) -> Bool {
        return History.contains(date.danFormat)
    }
    func Streak(from: Date) -> Int {
        var streak = 0
        if (History.count == 0) {
            return streak
        }
        
        var checkDate = from.dateOnly
        if (!DoneOnDate(date: checkDate)){    // count a streak that is up to yesterday
            checkDate = checkDate.yesterday
        }
        while(true)
        {
            if (DoneOnDate(date: checkDate))
            {
                streak += 1
                checkDate = checkDate.yesterday
            }
            else
            {
                break
            }
        }
        
        return streak;
    }
    func buttonText(from: Date) -> String {
        if (Streak(from: from) > 0){
            return Name + "⛓️"
        }
        return Name
    }
    func Details(from: Date) -> String {
        let streak = Streak(from: from)
        var streakString: String = ""
        var doneString: String = " L:\(LastDoneString())"
        if (streak > 0){
            streakString = " ⛓️:\(streak)"
            doneString = ""
        }
        if (DoneOnDate(date: Date().dateOnly)){
            doneString = " ✅"
        }
        return "D:\(History.count)\(doneString)\(streakString)"
    }
    mutating func SetDone(date: Date)
    {
        History.append(date.danFormat)
    }
    mutating func SetUnDone(date: Date)
    {
        History.removeAll(where: { $0 == date.danFormat })
    }

    enum CodingKeys: String, CodingKey {
        case id
        case Name
        case History
    }
    var id = UUID() // Automatically generate a unique identifier
    var Name: String
    var History: [String] = []
}

extension Date {
    /// Returns the date with time set to midnight (00:00:00)
    var dateOnly: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self) ?? Date()
    }
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self) ?? Date()
    }
    var danFormat: String {
        //let n = LastDone!.formatted(date: .numeric, time: .omitted)
        //let c = LastDone!.formatted(date: .complete, time: .omitted)
        //let l = LastDone!.formatted(date: .long, time: .omitted)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Specify the format
        return formatter.string(from: self)
    }
    
}


