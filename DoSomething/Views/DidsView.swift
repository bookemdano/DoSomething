//
//  DidsView.swift
//  MacLab
//
//  Created by Daniel Francis on 1/8/25.
//

import SwiftUICore
import SwiftUI
import DanSwiftLib

struct DidsView: View {
    @State private var _welcomed: Bool = (IOPAws.getUserID() != nil)
    @State private var _didList: DidList = .init()
    @State private var _owner: String = IOPAws.getUserID() ?? "Template"
    @State private var _showingAlert = false
    @State private var _deleteItem: String = ""
    @State private var _groups:[String: [Did]] = [:]
    @State private var _pointsHistory : [Int] = []
    var body: some View {
        VStack{
            List{
                ForEach(_groups.keys.sorted(), id: \.self){
                    group in
                    Section{
                        Text(group)
                        ForEach(_groups[group]!, id: \.self) { item in
                            NavigationLink(destination: DidView(did: item)){
                                HStack
                                {
                                    Text(item.NameString())
                                        .font(.headline)
                                    //.strikethrough(!item.IsAvailable())
                                    Spacer()
                                    Text(item.NotesFlag())
                                    Text(item.Details(from: Date()))
                                }
                                .padding(5)
                                
                            }
                            .listRowBackground(item.color(done: false, from: Date()))
                        }
                    }
                }
                //.onDelete(perform: deleteItem)
            }
            Spacer()
            TimelineView(.animation) { timelineContext in
                Canvas(
                    opaque: true,
                    colorMode: .linear,
                    rendersAsynchronously: false
                ) { context, size in
                    var path : Path = Path()
                    //path.move(to: CGPoint(x: 0, y: size.height))
                    if (_pointsHistory.count > 0)
                    {
                        var x = 0
                        let xfactor = Int(size.width) / _pointsHistory.count
                        let pointsmax = (_pointsHistory.max(by: {$0 < $1}) ?? 50)
                        let ymax = ((pointsmax / 5) + 1)*5
                        let yfactor = Int(size.height) / ymax
                        _pointsHistory.forEach { points in
                            let y = (ymax - points) * yfactor
                            path.addLine(to: CGPoint(x:x, y:y))
                            x += xfactor
                        }
                        context.stroke(
                            path,
                            with: .color(.green),
                            lineWidth: 3
                        )
                    }
                }
                .frame(height: 150)
                .background(Color.black)
            }
            Spacer()
            if (!_welcomed)
            {
                SignInWithAppleButtonView($_welcomed)
            }else{
                Button(action: {
                    IOPAws.clearUserID()
                    _welcomed = false
                    Refresh()
                }){
                    Text("Sign Out")
                }
            }
            NavigationLink(destination: DidView(did: Did(name: "New Item", category: nil, points: 1))) {
                Text("New Item").bold()
            }
        }
        .navigationTitle("Maintenance")
        .refreshable {
            Refresh()
        }
        .onAppear {
            Refresh()
        }
        
    }
    func deleteItem(at offset: IndexSet) {
        
        let keysArray = Array(_groups.keys)
        //let str = offset.first?.description
        //_groups.indices.first(where: offset.contains)
        
        let key = keysArray.indices.first(where: offset.contains)
        if key != nil {
            //dictionary.removeValue(forKey: keyToRemove)
            print("Removed key: \(key!)")
        } else {
            print("Offset is out of bounds")
        }

        //var items = _didList.GetGroups().indices.first(where: offset.contains)
        //_didList.Dids.remove(atOffsets: offset)
        Task {
            await DidPersist.SaveAsync(didList: _didList)
            Refresh()
        }
    }
    
    func add(_ didName: String)
    {
        if (_didList.Dids.count(where: { $0.Name == didName }) > 0) {
            return;
        }
        _didList.Add(name: didName)
        Task {
            await DidPersist.SaveAsync(didList: _didList)
            Refresh()
        }
    }
    func changeOwner(_ owner: String)
    {
        //IOPAws.ChangeOwner(owner: owner)
        Refresh()
    }
    
    func Refresh()
    {
        Task{
            _didList.Dids = await DidPersist.Read()
            _groups = _didList.GetGroups(includeDone: true)
            _pointsHistory.removeAll()
            var date = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            while(date <= Date())
            {
                _pointsHistory.append(_didList.DonePoints(date: date))
                date = date.tomorrow
            }
        }
       
    }
}
