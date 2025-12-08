//
//  WatchRoutineStore.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 12/8/25.
//

import Foundation
import Combine

class WatchRoutineStore: ObservableObject {
    static let shared = WatchRoutineStore()
    
    @Published var routines: [WorkoutRoutine] = []
    
    private let userDefaultsKey = "savedRoutines"
    
    private init() {
        self.routines = loadRoutines()
    }
    
    func save(routines: [WorkoutRoutine]) {
        do {
            let data = try JSONEncoder().encode(routines)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            DispatchQueue.main.async {
                self.routines = routines
            }
            print("WatchRoutineStore: \(routines.count)개 루틴 저장완료")
        } catch {
            print("WatchRoutineStore: 루틴 저장 실패 - \(error.localizedDescription)")
        }
    }
    
    private func loadRoutines() -> [WorkoutRoutine] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print("WatchRoutineStore: 루틴 데이터 없음!")
            return []
        }
        
        do {
            let decodedRoutines = try JSONDecoder().decode([WorkoutRoutine].self, from: data)
            print("WatchRoutineStore:\(decodedRoutines.count)개 루틴 정보 디코딩, 로드 성공")
            return decodedRoutines
        } catch {
            print("WatchRoutineStore: 로드된 루틴 디코딩 실패 \(error.localizedDescription)")
            return []
        }
    }
}
