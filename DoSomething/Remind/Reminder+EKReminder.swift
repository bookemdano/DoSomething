/*
 See LICENSE folder for this sample’s licensing information.
 */

import EventKit
import Foundation

extension Reminder {
    init(with ekReminder: EKReminder) {
        //guard let dueDate = ekReminder.alarms?.first?.absoluteDate else {
        //    throw TodayError.reminderHasNoDueDate
        //}
        id = ekReminder.calendarItemIdentifier
        title = ekReminder.title
        dueDate = ekReminder.alarms?.first?.absoluteDate
        if (dueDate == nil) {
            dueDate = ekReminder.dueDateComponents?.date
        }
        notes = ekReminder.notes
        isComplete = ekReminder.isCompleted
        completionDate = ekReminder.completionDate
    }
}
