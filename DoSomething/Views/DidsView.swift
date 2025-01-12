//
//  DidsView.swift
//  MacLab
//
//  Created by Daniel Francis on 1/8/25.
//

import SwiftUICore
import SwiftUI

struct DidsView: View {
    let _iop = IOPAws(app: "ToDone")
    @State private var _didList: DidList = .init()
    @State private var _newDid: String = ""
    @State private var _showingAlert = false
    @State private var _deleteItem: String = ""
    var body: some View {
        VStack{
            List{
                ForEach(_didList.Dids){ item in
                    NavigationLink(destination: DidView(did: item)){
                        HStack
                        {
                            Text(item.Name).font(.headline)
                            Spacer()
                            Text(item.Details(from: Date()))
                        }
                    }
                }
                .onDelete(perform: deleteItem)
            }
            Spacer()
            HStack {
                Spacer()
                TextField("New action", text: $_newDid)
                Button(action: {
                    add(_newDid)
                    _newDid = ""
                }){
                    Text("Add")
                }
                Spacer()
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
        _didList.Dids.remove(atOffsets: offset)
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
    
    func Refresh()
    {
        Task{
            _didList.Dids = await DidPersist.Read()
        }
       
    }
}
