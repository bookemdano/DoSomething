//
//  ContentView.swift
//  MacLab
//
//  Created by Daniel Francis on 1/3/25.
//

import SwiftUI

struct ContentView: View {
    @State private var _didList: DidList = .init()
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
                FlowLayout(items: _didList.GetDids(date: _date), spacing: 10){ item in
                    Button(action: {
                        undone(item)
                    }) {
                        Text(item.buttonText(from: _date))
                    }
                    .padding(5)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(20)
                }.background(Color.green.opacity(0.1))

                FlowLayout(items: _didList.GetDidnts(date: _date), spacing: 10){ item in
                    Button(action: {
                        done(item)
                    }) {
                        Text(item.buttonText(from: _date))
                    }
                    .padding(5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                }
                HStack {
                    NavigationLink(destination: DidsView()) {
                        Text("Maintenance")
                    }
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
            _didList.Dids = await DidPersist.Read()
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

