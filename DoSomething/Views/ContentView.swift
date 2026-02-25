//
//  ContentView.swift
//  MacLab
//
//  Created by Daniel Francis on 1/3/25.
//

import SwiftUI
#if canImport(DanSwiftLib)
import DanSwiftLib
#endif

struct ContentView: View {
#if canImport(DanSwiftLib)
    @State private var _welcomed: Bool = (IOPAws.getUserID() != nil)
#else
    @State private var _welcomed: Bool = true
#endif
    @State private var _didList: DidList = .init()
    @State private var _date: Date = Date().dateOnly
    @State private var _cat: String = "All"
    @Environment(\.scenePhase) private var scenePhase
    private var reminderStore: ReminderStore { ReminderStore.shared }
    @State private var reminders: [Reminder] = []
    @State private var _cachedDueReminders: [Reminder]? = nil
  
    var body: some View {
        NavigationView{
            if (!_welcomed) {
                #if canImport(DanSwiftLib)
                SignInWithAppleButtonView($_welcomed)
                #else
                Text("Not signed in")
                #endif
            } else {
                VStack{
                    HStack{
                        Button(action: {
                            Prev()
                        }){
                            Text("⏮️")
                        }
                        Text(_date.danFormat + " (\(ScoreText()))")
                            .bold().background(GetColor(_date))
                        Button(action: {
                            Next()
                        }){
                            Text("⏭️")
                        }
                    }
                    // done items
                    FlowLayout(items: _didList.GetDids(date: _date), spacing: 5){ item in
                        Button(action: {
                            undone(item)
                        }) {
                            Text(item.NameString()).bold()
                        }
                        .padding(5)
                        .background(item.color(done: true, from: _date))
                        //.background(.white)
                        .cornerRadius(10)
                        .overlay( // Add border
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 1)
                        )
                    }
                    // not done items
                    FlowLayout(items: _didList.GetDidnts(date: _date, cat: _cat), spacing: 10){ item in
                        Button(action: {
                            done(item)
                        }) {
                            Text(item.NameString()).bold()
                        }
                        .padding(5)
                        .background(item.color(done: false, from: _date))
                        .cornerRadius(10)
                        .overlay( // Add border
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 1)
                        )
                    }
                    HStack {
                        ForEach(_didList.GetCategories(), id: \.self) { cat in
                            Button(action: {
                                ChangeCat(cat)
                            }) {
                                Text(cat)
                                    .bold()
                                    .foregroundColor(CatForeground(cat))
                                    .background(.white)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .border(Color.gray)
                    
                    HStack {
                        NavigationLink(destination: DidsView()) {
                            Text("Maintenance")
                        }
                        Button(action: {
                            Refresh(reloadReminders: true)
                        }){
                            Text("🔄")
                        }
                    }
                }
                #if os(iOS)
                .refreshable {
                    Refresh(reloadReminders: true)
                }
                #endif
                .onAppear {
                    Refresh()
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                print("View is in the foreground")
                if (_date.dateOnly != Date().dateOnly){
                    print("View update to today")
                    _date = Date().dateOnly;
                    Refresh()
                }
            }
        }
    }
    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminders = try await reminderStore.readAll()
                _didList.AddReminders(reminders)
                let dueReminders = try await reminderStore.readDueAndOverdue()
                _cachedDueReminders = dueReminders
                _didList.AddDueReminders(dueReminders)
            } catch TodayError.accessDenied{
#if DEBUG
                reminders = Reminder.sampleData
#endif
            } catch TodayError.accessRestricted {
#if DEBUG
                reminders = Reminder.sampleData
#endif
            } catch {
                print(error)
            }
        }
    }
    func ScoreText() -> String {
        let didPts = _didList.DonePoints(date: _date)
        let remPts = _didList.ReminderPoints()
        let total = didPts + remPts
        let remSummary = _didList.ReminderSummary()
        if remSummary.isEmpty {
            return "\(total)"
        }
        return "\(total) \(remSummary)"
    }
    func CatForeground(_ cat: String) -> Color
    {
        if (cat == _cat){
            return Color.black
        } else {
            return Color.gray
        }
        
    }
    func ChangeCat(_ cat: String)
    {
        _cat = cat
        Refresh()
    }
    func Next()
    {
        _date = Calendar.current.date(byAdding: .day, value: 1, to: _date) ?? Date()
        if (_date > Date()){
            _date = Date()
        }
    }
    func Prev()
    {
        _date = Calendar.current.date(byAdding: .day, value: -1, to: _date) ?? Date()
    }
    func Refresh(reloadReminders: Bool = false){
        Task{
            _didList = await DidPersist.Read()
            // Restore cached reminder data immediately to avoid flash
            if let cached = _cachedDueReminders {
                _didList.AddDueReminders(cached)
            }
            if let cached = reminders as [Reminder]?, !cached.isEmpty {
                _didList.AddReminders(cached)
            }
            if reloadReminders || _cachedDueReminders == nil {
                prepareReminderStore()
            }
        }
    }

    func GetColor(_ date: Date) -> Color {
        if (date.dateOnly == Date().dateOnly){
            Color.cyan.opacity(0.1)
        }
        else {
            Color.red
        }
    }
    func done(_ did: Did)
    {
        _didList.Done(did: did, date: _date)
        DidPersist.SaveSync(didList: _didList)
    }
    func undone(_ did: Did) {
        _didList.UnDone(did: did, date: _date)
        DidPersist.SaveSync(didList: _didList)
     }
}

#Preview {
    ContentView()
}

