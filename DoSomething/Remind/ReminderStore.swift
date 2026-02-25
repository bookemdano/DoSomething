/*
 See LICENSE folder for this sample’s licensing information.
 */

import EventKit
import Foundation

final class ReminderStore {
    static let shared = ReminderStore()

    private let ekStore = EKEventStore()

    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
    }

    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .fullAccess:
            return
        case .restricted, .writeOnly:
            throw TodayError.accessRestricted
        case .notDetermined:
            let accessGranted = try await ekStore.requestFullAccessToReminders()
            guard accessGranted else {
                throw TodayError.accessDenied
            }
        case .denied:
            throw TodayError.accessDenied
        @unknown default:
            throw TodayError.unknown
        }
    }

    func readAll() async throws -> [Reminder] {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let predicate: NSPredicate  = ekStore.predicateForReminders(in: nil)
        /* new way
        var rv: [Reminder] = []
        if let aPredicate = predicate {
            ekStore.fetchReminders(matching: aPredicate, completion: {(_ reminders: [Any]?) -> Void in
                for ekReminder: EKReminder? in reminders as? [EKReminder?] ?? [EKReminder?]() {
                    if (ekReminder != nil && ekReminder?.isCompleted == false) {
                        rv.append(Reminder(with: ekReminder!))
                    }
                }
            })
        }
         return rv
          */
        //old way
        let ekReminders = try await ekStore.reminders(matching: predicate)
        let reminders: [Reminder?] = ekReminders.compactMap { ekReminder in
            if (ekReminder.isCompleted == false) {
                return Reminder(with: ekReminder)
            }else{
                return nil
            }
        }
        return reminders.compactMap{$0}

    }

    /// Fetches reminders due today or overdue that are incomplete, plus reminders completed today.
    func readDueAndOverdue() async throws -> [Reminder] {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let predicate = ekStore.predicateForReminders(in: nil)
        let ekReminders = try await ekStore.reminders(matching: predicate)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let endOfToday = startOfToday.addingTimeInterval(86400)
        return ekReminders.compactMap { ekReminder in
            let reminder = Reminder(with: ekReminder)
            guard let due = reminder.dueDate else { return nil }
            // Include if: incomplete and due today or overdue
            if !reminder.isComplete && due < endOfToday {
                return reminder
            }
            // Include if: completed today (regardless of original due date)
            if reminder.isComplete, let completed = reminder.completionDate,
               completed >= startOfToday && completed < endOfToday {
                return reminder
            }
            return nil
        }
    }
}
