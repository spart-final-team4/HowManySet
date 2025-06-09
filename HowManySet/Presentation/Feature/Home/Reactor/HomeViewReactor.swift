//
//  MainViewModel.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import Foundation
import RxSwift
import ReactorKit

final class HomeViewReactor: Reactor {
    
    private let saveRecordUseCase: SaveRecordUseCase
    
    private let routineMockData = WorkoutRoutine.mockData[0]
    
    // Action is an user interaction
    enum Action {
        case routineSelected
        case routineComplete
//        case forward
//        case stop
//        case option
//        case pause
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case startRoutine(Bool)
        case startRest(Bool)
        case restTimeUpdating
        case restTimeEnded
//        case forwardToNextSet
//        case presentOption(Bool)
//        case pauseWorkout(Bool)
    }
    
    // State is a current view state
    struct State {
        
        var workoutTime: Int
        var isWorkingout: Bool
                
        // 운동 관련
        var routineName: String
        var exerciseName: String
        var weight: Double
        var unit: String
        var reps: Int
        var currentSet: Int
        var totalSet: [WorkoutSet]
        var date: Date
        var comment: String?
        
        // 휴식 관련
        var isResting: Bool
        var restSecondsRemaining: Int
        var isRestPaused: Bool
        var restTime: Int
    }
    
    let initialState: State
    
    init(saveRecordUseCase: SaveRecordUseCase) {
        self.saveRecordUseCase = saveRecordUseCase
        self.initialState = State(
            workoutTime: 0,
            isWorkingout: false,
            routineName: routineMockData.name,
            exerciseName: routineMockData.workouts[0].name,
            weight: routineMockData.workouts[0].sets[0].weight,
            unit: routineMockData.workouts[0].sets[0].unit,
            reps: routineMockData.workouts[0].sets[0].reps,
            currentSet: 0,
            totalSet: routineMockData.workouts[0].sets,
            date: Date(),
            isResting: false,
            restSecondsRemaining: 0,
            isRestPaused: false,
            restTime: routineMockData.workouts[0].restTime
        )
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            
        case .routineSelected:
            return Observable.just(Mutation.startRoutine(true))
            
        case .routineComplete:
            let startRest = Observable.just(Mutation.startRest(true))
            let restTime = currentState.restTime
            let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .take(restTime)
                .map { _ in Mutation.restTimeUpdating }

            let endRest = Observable.just(Mutation.restTimeEnded)
            
            // startRest는 바로 방출, timer가 다 되면 timer, endRest 방출
            return Observable.concat([startRest, timer, endRest])
             
//        case .forward:
//
//        case .stop:
//            
//        case .option:
//            
//        case .pause:
            
        }
    }

    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {
        case let .startRoutine(isWorkingout):
            state.isWorkingout = isWorkingout
        case let .startRest(isResting):
            state.isResting = isResting
        case .restTimeUpdating:
            var currentRestTime = state.restTime
            currentRestTime = max(currentRestTime - 1, 0)
        case .restTimeEnded:
            state.isResting = false
            
//        case .forwardToNextSet:
//
//        case .stopRest:
//            
//        case .presentOption:
//            
//        case .pauseWorkout:
            
        }
        
        return state
    }
}
