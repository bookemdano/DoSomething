//
//  Did.swift
//  MacLab
//
//  Created by Daniel Francis on 1/6/25.
//

import Foundation
import SwiftUICore
// TODO every other day streaks or weekday streaks
// TODONE Mark items as "non-current" so only show up in maint
// TODO Faster streak check
struct Did : Codable, Hashable, Identifiable, Comparable
{
    static func < (lhs: Did, rhs: Did) -> Bool {
        return lhs.Name < rhs.Name
    }
    
    init(name: String, category: String?, points: Int) {
        Name = name
        Category = category
        Points = points
        Created = Date()
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
    // did if it was supposed to done and didn't if it is to be avoided
    func ContinuedOnDate(date: Date) -> Bool {
        var inHistory = History.contains(date.danFormat)
        if (Avoid == true) {
            if ( date < Created ?? Date()) {
                inHistory = false
            } else {
                inHistory = !inHistory
            }
        }
        return inHistory
    }

    func Streak(from: Date) -> Int {
        var streak = 0
        if (History.count == 0) {
            return streak
        }
        
        var checkDate = from.dateOnly
        if (!ContinuedOnDate(date: checkDate)){    // count a streak that is up to yesterday
            checkDate = checkDate.yesterday
        }
        while(true)
        {
            if (ContinuedOnDate(date: checkDate))
            {
                streak += 1
                checkDate = checkDate.yesterday
                //if (Avoid == true && checkDate < Created ?? Date()){
                //    break
                //}
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
    func color(done: Bool, from: Date) -> Color {
        let streak = Streak(from: from)
        if (streak == 0){
            return Color.gray.opacity(0.1)
        }
        else {
            var opp = Double(streak) / 10.0
            if (opp > 1){
                opp = 1
            }
            if (done) {
                return Color.green.opacity(opp)
            } else {
                return Color.orange.opacity(opp)
            }
        }
    }
    func NameString() -> String {
        var rv = Name
        if (Avoid == true)
        {
            rv += "🚭"
        }

        return rv;
    }
    func NotesFlag() -> String {
        if (Notes != nil && Notes != "") {
            return "(n)"
        }
        else{return "";}
    }
    func Details(from: Date) -> String {
        let streak = Streak(from: from)
        var streakString: String = ""
        var doneString: String = " L:\(LastDoneString())"
        var pointsString = ""
        if (streak > 0){
            streakString = " ⛓️:\(streak)"
            doneString = ""
        }
        if (ContinuedOnDate(date: Date().dateOnly)){
            doneString = " ✅"
        }
        if (GetPoints() > 1){
            pointsString = " " + String(GetPoints()) + "pts"
        }
            
        return "D:\(History.count)\(doneString)\(streakString)\(pointsString)"
    }
    mutating func SetAction(date: Date, continued: Bool)
    {
        if (date < Created ?? Date()) {
            Created = date
        }
        if (continued) {
            if (Avoid == true) {
                History.removeAll(where: { $0 == date.danFormat })
            } else {
                History.append(date.danFormat)
            }
        } else {
            if (Avoid == true) {
                History.append(date.danFormat)
            } else {
                History.removeAll(where: { $0 == date.danFormat })
            }
        }
    }


    func IsAvailable() -> Bool {
        if (Retired == true){
            return false
        }
        if (OneTime == true && !History.isEmpty){
            return false
        }
        return true
    }
    func GetCategory() -> String {
        let cat = Category ?? ""
        if (cat == "") {
            return "None"
        }
        return cat;
    }
    mutating func Init(){
        if (Points == nil){
            Points = 1
        }
        if (OneTime == nil){
            OneTime = false
        }
        if (Retired == nil){
            Retired = false
        }
        if (Avoid == nil){
            Avoid = false
        }
        if (Created == nil){
            Created = Did.parseDate(History.first ?? Date().danFormat)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case Name
        case Category
        case History
        case Points
        case OneTime
        case Retired
        case Notes
        case Avoid
        case Created
    }
    func GetPoints() -> Int {
        return Points ?? 1
    }
    var id = UUID() // Automatically generate a unique identifier
    var Name: String
    var Category: String? = nil
    var Points: Int? = 1
    var History: [String] = []
    var OneTime: Bool? = false
    var Retired: Bool? = false
    var Notes: String? = nil
    var Avoid: Bool? = false
    var Created: Date? = Date()
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


