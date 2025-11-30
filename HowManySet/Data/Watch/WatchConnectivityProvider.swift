//
//  WatchConnectivityProvider.swift
//  HowManySet
//
//  Created by 정근호 on 11/29/25.
//

import Foundation
import WatchConnectivity 

class WatchConnectivityProvider: NSObject, WCSessionDelegate {
    
    static let shared = WatchConnectivityProvider()
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("WCSession activated")
        } else {
            print("WCSession is not supported")
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    /// WCSession 활성화 완료 후
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error {
            print("WCSession activated failed: \(error.localizedDescription)")
            return
        }
        print("WCSession activation completed: \(activationState.rawValue)")
        
        // TODO: 활성화 완료 후 로직 추가 (데이터 전송 등..)
    }
    
    /// Watch -> iOS로 전환 시 (Inactive)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive.")
    }
    
    /// 세션 비활성화 후 다시 활성화 할 때
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated. Reactivating...")
        WCSession.default.activate() // 재활성화
    }
    
    /// iOS 또는 Watch 앱에서 데이터 수신 시 호출
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Received application context: \(applicationContext)")
        
        // TODO: 데이터 처리 로직 추가
    }
}
