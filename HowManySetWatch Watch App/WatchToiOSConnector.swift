//
//  WatchToiOSConnector.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 12/1/25.
//

import Foundation
import WatchConnectivity

class WatchToiOSConnector: NSObject, WCSessionDelegate {
    
    static let shared = WatchToiOSConnector()
    
    private let session: WCSession
    
    private override init() {
        self.session = .default
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WatchToiOSConnector: WCSession 활성화 실패: \(error.localizedDescription)")
        } else {
            print("WatchToiOSConnector: WCSession 활성화 완료: \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            guard let action = message["action"] as? String else {
                print("WatchToiOSConnector: 액션 메시지 없음.")
                return
            }
            
            print("WatchToiOSConnector: 액션 전달 성공: \(action)")
            
            switch action {
            // 루틴정보 동기화
            case "syncRoutines":
                if let routinesData = message["routines"] as? Data {
                    do {
                        let routines = try JSONDecoder().decode([WorkoutRoutine].self, from: routinesData)
                        WatchRoutineStore.shared.save(routines: routines)
                        print("WatchToiOSConnector: \(routines.count)개의 전달받은 루틴 저장완료")
                    } catch {
                        print("WatchToiOSConnector: 루틴 디코딩 실패 - \(error.localizedDescription)")
                    }
                } else {
                    print("WatchToiOSConnector: 'syncRoutines' 루틴 데이터 없음")
                }
                
            // 운동시작 시
            case "startWorkout":
                break
                
            default:
                print("WatchToiOSConnector: unknown action 받음 - \(action)")
            }
        }
    }
}
