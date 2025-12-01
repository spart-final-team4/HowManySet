//
//  WatchToiOSConnector.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 12/1/25.
//

import Foundation
import WatchConnectivity

class WatchToiOSConnector: NSObject, WCSessionDelegate {
    
    var session: WCSession
    
    init(session: WCSession) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
}
