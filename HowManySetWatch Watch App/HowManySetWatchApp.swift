//
//  HowManySetWatchApp.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/26/25.
//

import SwiftUI

@main
struct HowManySetWatch_Watch_AppApp: App {
    
    init() {
        // WatchConnectivity 활성화
        _ = WatchConnectivityProvider.shared
    }
    
    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}
