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
        
        case rest1ButtonClicked
        case rest2ButtonClicked
        case rest3ButtonClicked
        case restResetButtonClicked
        
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
        case mutateRestTime(Int)
        case resetRestTime
        //        case presentOption(Bool)
        //        case pauseWorkout(Bool)
    }
    
    // State is a current view state
    struct State {
        /// 전체 루틴 데이터! (변화 없음)
        var workoutRoutine: WorkoutRoutine
            
        // 현재 진행 중인 운동/세트의 인덱스
        // 이 두 인덱스가 변경되면 UI에 표시될 모든 관련 정보가 바뀜
        var exerciseIndex: Int
        var setIndex: Int
        
        var workoutTime: Int
        var isWorkingout: Bool
        var isWorkoutPaused: Bool
      
        // UI에 직접 표시될 값들 (Reactor에서 미리 계산하여 제공)
        var currentRoutineName: String
        var currentExerciseName: String
        var currentWeight: Double
        var currentUnit: String
        var currentReps: Int
        
        var totalExerciseCount: Int // 전체 운동 개수
        var totalSetCount: Int // 현재 운동의 전체 세트 개수
        var currentExerciseNumber: Int // UI용 "1 / N"에서 1
        var currentSetNumber: Int      // UI용 "1 / N"에서 1
        var setProgressAmount: Int
        
        var date: Date
        var comment: String?
        
        var isResting: Bool
        var restSecondsRemaining: Int
        var isRestPaused: Bool
        var restTime: Int // 기본 휴식 시간
    }
    
    let initialState: State
    
    init(saveRecordUseCase: SaveRecordUseCase) {
        self.saveRecordUseCase = saveRecordUseCase
        let initialRoutine = routineMockData
        let initialWorkout = initialRoutine.workouts[0]
        let initialSet = initialWorkout.sets[0]
        
        self.initialState = State(
            workoutRoutine: initialRoutine,
            exerciseIndex: 0, // 첫 운동 인덱스
            setIndex: 0, // 첫 세트 인덱스

            workoutTime: 0,
            isWorkingout: false,
            isWorkoutPaused: false,
            
            currentRoutineName: initialRoutine.name,
            currentExerciseName: initialWorkout.name,
            currentWeight: initialSet.weight,
            currentUnit: initialSet.unit,
            currentReps: initialSet.reps,
            
            totalExerciseCount: initialRoutine.workouts.count,
            totalSetCount: initialWorkout.sets.count,
            currentExerciseNumber: 1, // UI는 1부터 시작
            currentSetNumber: 1,      // UI는 1부터 시작
            setProgressAmount: 0,
            
            date: Date(),
            comment: nil,
            isResting: false,
            restSecondsRemaining: 0,
            isRestPaused: false,
            restTime: initialRoutine.restTime
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
            
        case .rest1ButtonClicked:
            return Observable .just(Mutation.mutateRestTime(60))
        case .rest2ButtonClicked:
            return Observable .just(Mutation.mutateRestTime(30))
        case .rest3ButtonClicked:
            return Observable .just(Mutation.mutateRestTime(10))
        case .restResetButtonClicked:
            return Observable .just(Mutation.resetRestTime)
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {
            
        case let .startRoutine(isWorkingout):
            state.isWorkingout = isWorkingout
            state.restSecondsRemaining = state.restTime // 초기 휴식 시간 설정
            
        case let .startRest(isResting):
            state.isResting = isResting
            state.restSecondsRemaining = state.restTime
            
        case .workoutTimeUpdating:
            state.workoutTime += 1
            
        case .restTimeUpdating:
            // 휴식 중일 때 1초씩 감소
            if state.isResting {
                state.restSecondsRemaining = max(state.restSecondsRemaining - 1, 0)
            }
            
        case .restTimeEnded:
            state.isResting = false
            state.restSecondsRemaining = state.restTime
            
        case .forwardToNextSet:
            let currentExerciseWorkouts = state.workoutRoutine.workouts[state.exerciseIndex]
            let currentExerciseTotalSets = currentExerciseWorkouts.sets.count
            
            if state.currentSetNumber < currentExerciseTotalSets { // 다음 세트 시
                // 세트 인덱스, 세트 번호, 프로그레스 바 진행률 증가
                state.setIndex += 1
                state.currentSetNumber += 1
                state.setProgressAmount += 1
                
                // 변경된 세트 인덱스에 따라 무게, 단위, 반복 횟수 업데이트
                let nextSet = currentExerciseWorkouts.sets[state.setIndex]
                state.currentWeight = nextSet.weight
                state.currentUnit = nextSet.unit
                state.currentReps = nextSet.reps
                
            } else { // 현재 운동의 마지막 세트 완료, 다음 운동으로 이동 또는 루틴 종료
                state.setProgressAmount += 1
                
                // 다음 운동 있는지 확인
                if state.exerciseIndex + 1 < state.workoutRoutine.workouts.count {
                    state.exerciseIndex += 1
                    state.setIndex = 0
                    
                    state.currentExerciseNumber += 1
                    state.currentSetNumber = 1
                    state.setProgressAmount = 0
                    
                    // 변경된 운동 인덱스와 세트 인덱스에 따라 모든 관련 정보 업데이트
                    let nextWorkout = state.workoutRoutine.workouts[state.exerciseIndex]
                    let nextSet = nextWorkout.sets[state.setIndex] // 새 운동의 첫 세트

                    state.currentExerciseName = nextWorkout.name
                    state.totalSetCount = nextWorkout.sets.count // 다음 운동의 총 세트 수로 업데이트
                    state.currentWeight = nextSet.weight
                    state.currentUnit = nextSet.unit
                    state.currentReps = nextSet.reps
                    
                } else { // 모든 운동 루틴 완료!
                    state.isWorkingout = false
                    print("운동 완료 화면 이동")
                }
            }
            
        case let .pauseAndPlayWorkout(isWorkoutPaused):
            state.isWorkoutPaused = isWorkoutPaused
            state.isRestPaused = isWorkoutPaused // 휴식 중에도 일시정지 상태를 공유
            
        case let .mutateRestTime(restTimeIncrement):
            state.restTime += restTimeIncrement
            state.restSecondsRemaining += restTimeIncrement
            
        case .resetRestTime:
            state.restTime = 0
        }
        
        return state
    }
    
    
    /// 휴식 타이머 Observable을 생성하고 반환하는 함수
    private func restartRestTimer(newRestTime: Int) -> Observable<Mutation> {
        let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .take(newRestTime) // 새로운 휴식 시간을 기준으로 take
            .map { _ in
                return Mutation.restTimeUpdating
            }
            .concat(Observable.just(.restTimeEnded)) // 타이머 완료 후 restTimeEnded가 방출되도록 보장
        
        return timer
    }
    
}


