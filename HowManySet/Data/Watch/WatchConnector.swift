//
//  WatchConnector.swift
//  HowManySet
//
//  Created by 정근호 on 12/1/25.
//

import Foundation
import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate {
    
    static let shared = WatchConnector()
    
    private let session: WCSession
    
    private override init() {
        self.session = .default
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print("WatchConnector: WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WatchConnector: WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // 이전 세션이 비활성화되면 새 세션을 활성화합니다.
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Watch로부터 메시지 수신 (향후 구현)
        print("WatchConnector: Received message: \(message)")
    }
}

// MARK: - iOS -> Watch Messaging
extension WatchConnector {
    
    /// 루틴 목록을 Watch로 동기화합니다.
    func sendRoutinesToWatch(_ routines: [WorkoutRoutine]) {
        guard session.isReachable else {
            print("WatchConnector: Watch is not reachable.")
            return
        }
        
        do {
            let routinesData = try JSONEncoder().encode(routines)
            let message: [String: Any] = ["action": "syncRoutines", "routines": routinesData]
            
            session.sendMessage(message, replyHandler: nil) { error in
                print("WatchConnector: Error sending routines message: \(error.localizedDescription)")
            }
        } catch {
            print("WatchConnector: Error encoding routines: \(error.localizedDescription)")
        }
    }
    
    func startWorkoutSessionOnWatch(with routine: WorkoutRoutine) {
        guard session.isReachable else {
            print("WatchConnector: Watch is not reachable.")
            return
        }
        
        do {
            let encodedRoutine = try JSONEncoder().encode(routine)
            let message: [String: Any] = ["action": "startWorkout", "routine": encodedRoutine]
            
            session.sendMessage(message, replyHandler: nil) { error in
                print("WatchConnector: Error sending startWorkout message: \(error.localizedDescription)")
            }
        } catch {
            print("WatchConnector: Error encoding routine for startWorkout: \(error.localizedDescription)")
        }
    }
}
