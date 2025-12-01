//
//  WatchConnector.swift
//  HowManySet
//
//  Created by 정근호 on 12/1/25.
//

import Foundation
import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate {
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}

// MARK: - Workout Session Control
extension WatchConnector {
    func startWorkoutSessionOnWatch(with routine: WorkoutRoutine) {
        // WCSession 지원, Watch 설치 확인
        guard WCSession.default.isReachable else { return }
        
        do {
            let encodedRoutine = try JSONEncoder().encode(routine)
            let message = ["startWorkout": encodedRoutine]
            
            WCSession.default.sendMessage(message) { reply in
                print("Routine 전달 성공: \(reply)")
            } errorHandler: { error in
                print("Routine 전달 실패: \(error.localizedDescription)")
            }
        } catch {
            print("Routine 인코딩 실패: \(error.localizedDescription)")
        }
    }
}
