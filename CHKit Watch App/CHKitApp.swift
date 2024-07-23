//
//  CHKitApp.swift
//  CHKit Watch App
//
//  Created by evan on 2023/10/26.
//

import SwiftUI

@main
struct CHKit_Watch_AppApp: App {
    
    @StateObject private var watchConnectivityManager = CHWatchConnectivityManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchConnectivityManager)
        }
    }
}
