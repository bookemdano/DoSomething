//
//  DidView.swift
//  MacLab
//
//  Created by Daniel Francis on 1/10/25.
//

import SwiftUICore
import SwiftUI

struct DidView: View {
    let did: Did
    @State var _didName: String = ""
    @State var _points: String = "1"
    @State var _oneTime: Bool = false
    @State var _retired: Bool = false
    var body: some View {
        VStack
        {
            Text("Name: ")
            TextField("Name", text: $_didName)
                .background(Color.yellow.opacity(0.2))
            Text("Points: ")
            TextField("points", text: $_points)
                .keyboardType(.numberPad)
                .background(Color.yellow.opacity(0.2))
            Text("Streak: \(did.Streak(from: Date()))")
            Toggle("One-time", isOn: $_oneTime)
            Toggle("Retired", isOn: $_retired)
            //.font(.largeTitle)
            List(did.History.sorted(by: >), id: \.self) { history in
                Text(HistoryText(history: history))
                    .background(did.color(done: true, from: Did.parseDate(history)!))
            
            }
            Button(action: {
                Save()
            }){
                Text("Save")
            }
        }
        .onAppear {
            _didName = did.Name
            _points = String(did.GetPoints())
            _retired = did.Retired ?? false
            _oneTime = did.OneTime ?? false
        }
        .navigationTitle(did.Name)
    }
    func HistoryText(history:String) -> String {
        
        var txt:String = history
        if (did.Streak(from: Did.parseDate(history)!) > 1){
            txt = "⛓️\(txt)"
        }
        return txt
    }
    func Save()
    {
        Task {
            await DidPersist.UpdateDid(id: did.id, name: _didName, points: Int(_points) ?? 1, oneTime: _oneTime, retired: _retired)
        }
    }

}
