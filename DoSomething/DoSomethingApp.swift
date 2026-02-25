//
//  DoSomethingApp.swift
//  DoSomething
//
//  Created by Daniel Francis on 1/12/25.
//

import SwiftUI

@main
struct DoSomethingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().preferredColorScheme(.light)
        }
        #if os(macOS)
        .defaultSize(width: 600, height: 700)
        #endif
    }
}
// TODO add button types- line one could be mediation time, one could be the whole rushit app with subtypes
// TODO add a quote of the day

