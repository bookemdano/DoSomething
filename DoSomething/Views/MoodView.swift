//
//  MoodView.swift
//  DoSomething
//
//  Created by Daniel Francis on 1/24/25.
//

import SwiftUI

struct MoodView: View {
    @State private var _moodSet: MoodSet = .GetDefault()
    @State private var _date: Date = Date().dateOnly
    
    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    Button(action: {
                        Prev()
                    }){
                        Text("⏮️")
                    }
                    Text(_date.danFormat)
                        .bold()
                    Button(action: {
                        Next()
                    }){
                        Text("⏭️")
                    }
                }
                FlowLayout(items: _moodSet.GetItems(date: _date, status: .Up), spacing: 10){ item in
                    Button(action: {
                        Move(moodItem: item, moveFrom: .Up)
                    }) {
                        Text(item.Name).bold()
                    }
                    .padding(5)
                    //.background(item.color(done: false, from: _date))
                    .cornerRadius(10)
                }.background(Color.green.opacity(0.1))
                FlowLayout(items: _moodSet.GetItems(date: _date, status: .NA), spacing: 10){ item in
                    Button(action: {
                        Move(moodItem: item, moveFrom: .NA)
                    }) {
                        Text(item.Name).bold()
                    }
                    .padding(5)
                    //.background(item.color(done: false, from: _date))
                    .cornerRadius(10)
                }.background(Color.gray.opacity(0.1))
                FlowLayout(items: _moodSet.GetItems(date: _date, status: .Down), spacing: 10){ item in
                    Button(action: {
                        Move(moodItem: item, moveFrom: .Down)
                    }) {
                        Text(item.Name).bold()
                    }
                    .padding(5)
                    //.background(item.color(done: false, from: _date))
                    .cornerRadius(10)
                }.background(Color.blue.opacity(0.1))

                HStack {
                    Button(action: {
                        Refresh()
                    }){
                        Text("🔄")
                    }
                }
            }
            .refreshable {
                Refresh()
            }
            .onAppear {
                Refresh()
            }
        }
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
    func Refresh(){
        Task{
            _moodSet.Refresh(other: await MoodPersist.Read(), date: _date);
        }
    }
    
    func Move(moodItem: MoodItem, moveFrom: MoodStatusEnum)
    {
        _moodSet.Move(date: _date, moodItem: moodItem, moveFrom: moveFrom)
        MoodPersist.SaveSync(moodSet: _moodSet)
    }
}
