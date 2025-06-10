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
        case routineCompleteButtonClicked // 운동 완료 버튼 클릭 시
        case forwardButtonClicked // 휴식 스킵? 다음 세트?
        case pauseButtonClicked // 운동 중지 버튼 클릭 시
        //        case weightChanged
        //        case repsChanged
        //        case stop
        //        case option
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case startRoutine(Bool)
        case startRest(Bool)
        case workoutTimeUpdating
        case restTimeUpdating
        case restTimeEnded
        case forwardToNextSet
        case pauseAndPlayWorkout(Bool)
        //        case presentOption(Bool)
        //        case pauseWorkout(Bool)
    }
    
    // State is a current view state
    struct State {
        
        var workoutTime: Int
        var isWorkingout: Bool
        var isWorkoutPaused: Bool
        
        // 운동 관련
        var routineName: String
        var exerciseName: String
        var weight: Double
        var unit: String
        var reps: Int
        var currentSet: Int
        var setProgress: Int
        var setCount: Int
        var currentExercise: Int
        var exerciseCount: Int
        var totalSetsInfo: [WorkoutSet]
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
            isWorkoutPaused: false,
            routineName: routineMockData.name,
            exerciseName: routineMockData.workouts[0].name,
            weight: routineMockData.workouts[0].sets[0].weight,
            unit: routineMockData.workouts[0].sets[0].unit,
            reps: routineMockData.workouts[0].sets[0].reps,
            currentSet: 1,
            setProgress: 0,
            setCount: routineMockData.workouts[0].sets.count,
            currentExercise: 1,
            exerciseCount: routineMockData.workouts.count,
            totalSetsInfo: routineMockData.workouts[0].sets,
            date: Date(),
            isResting: false,
            restSecondsRemaining: 0,
            isRestPaused: false,
            restTime: routineMockData.restTime
        )
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        
        print(#function)
        
        switch action {
            
        case .routineSelected:
            let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .withLatestFrom(self.state.map{ $0.isWorkoutPaused }) { _, isPaused in return isPaused }
                .filter { !$0 }
                .map { _ in Mutation.workoutTimeUpdating }
            
            return Observable.concat([
                .just(Mutation.startRoutine(true)),
                timer
            ])
            
        case .routineCompleteButtonClicked:
            let startRest = Observable.just(Mutation.startRest(true))
            let restTime = currentState.restTime
            let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .take(restTime)
                .map { _ in
                    return Mutation.restTimeUpdating
                }
            
            // startRest는 바로 방출, timer가 다 되면 timer, endRest 방출
            return Observable.concat([
                startRest,
                timer,
                .just(.restTimeEnded),
                .just(.forwardToNextSet)])
            
        case .forwardButtonClicked:
            return Observable.just(Mutation.startRest(false))
            
        case .pauseButtonClicked:
            return Observable .just(Mutation.pauseAndPlayWorkout(!currentState.isWorkoutPaused))
                        
            //        case .repsChanged:
            //
            //        case .stop:
            //
            //        case .option:
            //
            
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {
            
        case let .startRoutine(isWorkingout):
            state.isWorkingout = isWorkingout
            state.restSecondsRemaining = state.restTime
            
        case let .startRest(isResting):
            state.isResting = isResting
            
        case .workoutTimeUpdating:
            state.workoutTime += 1
            
        case .restTimeUpdating:
            state.restSecondsRemaining = max(state.restSecondsRemaining - 1, 0)
            
        case .restTimeEnded:
            state.isResting = false
            state.restSecondsRemaining = state.restTime
            
        case .forwardToNextSet:
            if state.currentSet > state.setCount {
                // TODO: 다음 세트로 이동
            } else if state.currentSet == state.setCount {
                state.setProgress += 1
            } else {
                state.currentSet += 1
                state.setProgress += 1
            }
            
        case let .pauseAndPlayWorkout(isWorkoutPaused):
            state.isWorkoutPaused = isWorkoutPaused
            
            
        }
        
        return state
    }
}
