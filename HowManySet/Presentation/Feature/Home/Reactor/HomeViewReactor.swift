//
//  MainViewModel.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import Foundation
import RxSwift
import ReactorKit

/// 사용자에게 보여지는 운동 종목 카드 뷰의 정보를 담은 구조체
struct WorkoutCardState: Equatable {
    
    // UI에 직접 표시될 값들 (Reactor에서 미리 계산하여 제공)
    var currentExerciseName: String
    var currentWeight: Double
    var currentUnit: String
    var currentReps: Int
    /// 현재 진행 중인 세트 인덱스
    var setIndex: Int
    
    /// 전체 운동 개수
    var totalExerciseCount: Int
    /// 현재 운동의 전체 세트 개수
    var totalSetCount: Int
    /// UI용 "1 / N"에서 1
    var currentExerciseNumber: Int
    /// UI용 "1 / N"에서 1
    var currentSetNumber: Int
    /// 세트 프로그레스바
    var setProgressAmount: Int
    
    /// 현재 운동 종목의 메모
    var commentInExercise: String?
}

final class HomeViewReactor: Reactor {
    
    private let saveRecordUseCase: SaveRecordUseCase
    
    private let routineMockData = WorkoutRoutine.mockData[0]
    
    // MARK: - Action is an user interaction
    enum Action {
        /// 루틴 선택 시 (현재는 바로 시작, but 추후에 루틴 선택 창 present)
        case routineSelected
        /// 세트! 완료 버튼 클릭 시
        case setCompleteButtonClicked
        /// 휴식 스킵? 다음 세트?
        case forwardButtonClicked
        /// 운동 중지 버튼 클릭 시
        case pauseButtonClicked
        
        // 휴식 시간 조정 버튼 관련
        case rest1ButtonClicked
        case rest2ButtonClicked
        case rest3ButtonClicked
        case restResetButtonClicked
        
        //        case stop
        //        case option
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case startRoutine(Bool)
        case startRest(Bool)
        case workoutTimeUpdating
        case restRemainingSecondsUpdating
        case restTimeEnded
        case forwardToNextSet
        case pauseAndPlayWorkout(Bool)
        case mutateRestTime(Int)
        case resetRestTime
        //        case stopWorkout(Bool)
        //        case presentOption(Bool)
    }
    
    // MARK: - State is a current view state
    struct State {
        /// 전체 루틴 데이터! (운동 진행 중일 시 변화 없음)
        var workoutRoutine: WorkoutRoutine
        
        // 현재 진행 중인 운동/세트의 인덱스
        // 이 두 인덱스가 변경되면 UI에 표시될 모든 관련 정보가 바뀜
        /// 첫 운동 인덱스
        var exerciseIndex: Int
        /// 첫 세트 인덱스
        var setIndex: Int
        
        var workoutTime: Int
        /// 운동 시작 시 운동 중
        var isWorkingout: Bool
        /// 운동 중지 시
        var isWorkoutPaused: Bool
        
        // UI에 직접 표시될 값들 (Reactor에서 미리 계산하여 제공)
        var currentRoutineName: String
        var currentExerciseName: String
        var currentWeight: Double
        var currentUnit: String
        var currentReps: Int
        
        /// 전체 운동 개수
        var totalExerciseCount: Int
        /// 현재 운동의 전체 세트 개수
        var totalSetCount: Int
        /// UI용 "1 / N"에서 1
        var currentExerciseNumber: Int
        /// UI용 "1 / N"에서 1
        var currentSetNumber: Int
        var setProgressAmount: Int
        
        var date: Date
        var comment: String?
        
        var isResting: Bool
        var isRestPaused: Bool
        /// 프로그레스바에 사용될 현재 휴식 시간 (사용자가 버튼으로 변경 시 즉시 변경 안됨)
        var restSecondsRemaining: Float
        /// 기본 휴식 시간 (사용자가 버튼으로 변경 시 즉시 변경)
        var restTime: Int
        /// 휴식이 시작될 때의 값!
        var restStartTime: Int?
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
            currentSetNumber: 1, // UI는 1부터 시작
            setProgressAmount: 0,
            
            date: Date(),
            comment: nil,
            isResting: false,
            isRestPaused: false,
            restSecondsRemaining: 0,
            restTime: initialRoutine.restTime
        )
    }
    
    // MARK: - Mutate(Action -> Mutation)
    func mutate(action: Action) -> Observable<Mutation> {
        
        print(#function)
        
        switch action {
            
        case .routineSelected:
            // 운동 시간 타이머 설정
            let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .withLatestFrom(self.state.map{ $0.isWorkoutPaused }) { _, isPaused in return isPaused }
                .filter { !$0 }
                .map { _ in Mutation.workoutTimeUpdating }
            
            return Observable.concat([
                .just(Mutation.startRoutine(true)),
                timer
            ])
        
        // 세트 완료 버튼 클릭 시 휴식 프로그레스 바 관련 로직
        case .setCompleteButtonClicked:
            let startRest = Observable.just(Mutation.startRest(true))
            let restTime = currentState.restTime
            let interval = 0.01
            let tickCount = Int(Double(restTime) / interval)
            let timer = Observable<Int>.interval(.milliseconds(Int(interval * 1000)), scheduler: MainScheduler.instance)
                .take(tickCount)
                .map { _ in return Mutation.restRemainingSecondsUpdating }
            
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
    
    // MARK: - Reduce(Mutation -> State)
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {
            
        case let .startRoutine(isWorkingout):
            state.isWorkingout = isWorkingout
            
        case let .startRest(isResting):
            state.isResting = isResting
            
            if isResting {
                state.restStartTime = state.restTime // 그 시점의 값을 고정 저장
                state.restSecondsRemaining = Float(state.restTime)
            } else {
                state.restStartTime = nil
                state.restSecondsRemaining = 0
            }
            
        case .workoutTimeUpdating:
            state.workoutTime += 1
            
        case .restRemainingSecondsUpdating:
            if state.isResting {
                    state.restSecondsRemaining = max(state.restSecondsRemaining - 0.01, 0)
            }
            
        case .restTimeEnded:
            state.isResting = false
            
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
            state.isRestPaused = isWorkoutPaused // 휴식 중에도 일시정지 상태 공유
            
        case let .mutateRestTime(restTimeIncrement):
            state.restTime += restTimeIncrement
            
        case .resetRestTime:
            state.restTime = 0
            
        }
        return state
    }
}


