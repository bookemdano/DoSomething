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
    @Environment(\.presentationMode) var presentationMode
    @State private var _showDeleteConfirmation = false
    @State var _didName: String = ""
    @State var _points: String = "1"
    @State var _notes: String = ""
 @State var _oneTime: Bool = false
    @State var _retired: Bool = false
    var body: some View {
        VStack
        {
            HStack{
                Text("Name: ")
                TextField("Name", text: $_didName)
                    .border(Color.gray)
            }
            HStack{
                Text("Points: ")
                TextField("points", text: $_points)
                    .keyboardType(.numberPad)
                    .border(Color.gray)
            }
            Text("Notes: ")
            TextEditor(text: $_notes)
                .frame(height: 80)
                .border(Color.gray)
            Text("Streak: \(did.Streak(from: Date()))")
            Toggle("One-time", isOn: $_oneTime)
            Toggle("Retired", isOn: $_retired)
            //.font(.largeTitle)
            List(did.History.sorted(by: >), id: \.self) { history in
                Text(HistoryText(history: history))
                    .background(did.color(done: true, from: Did.parseDate(history)!))
            
            }
            HStack{
                Button(action: {
                    Save()
                }){
                    Text("Save")
                }.padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                Button("Delete") {
                    _showDeleteConfirmation = true
                }.padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                .confirmationDialog("Are you sure?", isPresented: $_showDeleteConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        Delete()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action cannot be undone. Deleting means it never was.")
                }
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("Cancel")
                }.padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

        }
        .padding(5)
        .onAppear {
            _didName = did.Name
            _points = String(did.GetPoints())
            _retired = did.Retired ?? false
            _oneTime = did.OneTime ?? false
            _notes = did.Notes ?? ""
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
    
    func Delete()
    {
        Task {
            await DidPersist.RemoveDid(id: did.id)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func Save()
    {
        Task {
            await DidPersist.UpdateDid(id: did.id, name: _didName, points: Int(_points) ?? 1, oneTime: _oneTime, retired: _retired, notes: _notes)
            presentationMode.wrappedValue.dismiss()
        }
    }

}
