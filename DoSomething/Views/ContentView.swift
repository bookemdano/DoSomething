//
//  ContentView.swift
//  MacLab
//
//  Created by Daniel Francis on 1/3/25.
//

import SwiftUI
import DanSwiftLib

struct ContentView: View {
    @State private var _didList: DidList = .init()
    @State private var _date: Date = Date().dateOnly
    @State private var _cat: String = "All"
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    Button(action: {
                        Prev()
                    }){
                        Text("⏮️")
                    }
                    Text(_date.danFormat + "(\(_didList.DonePoints(date: _date)))")
                        .bold()
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
                        Text(item.Name).bold()
                    }
                    .padding(5)
                    .background(item.color(done: true, from: _date))
                    .cornerRadius(10)
                }.background(GetColor(_date))
                Text(DanSwiftLib.hello())
                // not done items
                FlowLayout(items: _didList.GetDidnts(date: _date, cat: _cat), spacing: 10){ item in
                    Button(action: {
                        done(item)
                    }) {
                        Text(item.Name).bold()
                    }
                    .padding(5)
                    .background(item.color(done: false, from: _date))
                    .cornerRadius(10)
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
    func Refresh(){
        Task{
            _didList.Dids = await DidPersist.Read()
        }
    }

    func GetColor(_ date: Date) -> Color {
        if (date.dateOnly == Date().dateOnly){
            Color.green.opacity(0.1)
        }
        else {
            Color.red.opacity(0.5)
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

