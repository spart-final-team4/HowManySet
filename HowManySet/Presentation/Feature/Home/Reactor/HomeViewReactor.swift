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
        
        /// 현재 루틴의 전체 각 운동의 State
        var workoutCardStates: [WorkoutCardState]

        /// 현재 진행 중인 루틴 안 운동의 인덱스
        var exerciseIndex: Int
        /// 운동 시작 시 운동 중
        var isWorkingout: Bool
        /// 운동 중지 시
        var isWorkoutPaused: Bool
        var workoutTime: Int
        
        var date: Date
        var commentInRoutine: String?
        
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
        // 루틴 선택 시 초기 값 설정 (그 후 변동)
        let initialRoutine = routineMockData
        let initialWorkout = initialRoutine.workouts[0]
        
        var workoutCardStates: [WorkoutCardState] = []
        // 현재 루틴의 모든 정보를 workoutCardStates에 저장
        for (i, workout) in initialRoutine.workouts.enumerated() {
            let firstSet = workout.sets.first!
            workoutCardStates.append(WorkoutCardState(
                currentExerciseName: workout.name,
                currentWeight: firstSet.weight,
                currentUnit: firstSet.unit,
                currentReps: firstSet.reps,
                setIndex: 0,
                totalExerciseCount: initialRoutine.workouts.count,
                totalSetCount: workout.sets.count,
                currentExerciseNumber: i + 1,
                currentSetNumber: 1,
                setProgressAmount: 0,
                commentInExercise: workout.comment
            ))
        }
        
        self.initialState = State(
            workoutRoutine: initialRoutine,
            workoutCardStates: workoutCardStates,
            exerciseIndex: 0, // 첫 운동 인덱스
            
            isWorkingout: false,
            isWorkoutPaused: false,
            workoutTime: 0,
            
            date: Date(),
            commentInRoutine: nil,
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
            let currentExerciseIndex = state.exerciseIndex
            var cardState = state.workoutCardStates[currentExerciseIndex]
            let workout = state.workoutRoutine.workouts[currentExerciseIndex]
            
            let nextSetIndex = cardState.setIndex + 1
            
            if nextSetIndex < workout.sets.count { // 다음 세트 시
                
                let nextSet = workout.sets[nextSetIndex]
                
                // 세트 인덱스, 세트 번호, 프로그레스 바 진행률 등 세트 정보 업데이트
                cardState.setIndex = nextSetIndex
                cardState.currentSetNumber += 1
                cardState.setProgressAmount += 1
                cardState.currentWeight = nextSet.weight
                cardState.currentReps = nextSet.reps
                cardState.currentUnit = nextSet.unit
                
                // 배열 업데이트
                state.workoutCardStates[currentExerciseIndex] = cardState
                
            } else { // 현재 운동의 마지막 세트 완료, 다음 운동으로 이동 또는 루틴 종료
                cardState.setProgressAmount += 1
                let nextExerciseIndex = currentExerciseIndex + 1
                
                // 다음 운동 있는지 확인
                if nextExerciseIndex < state.workoutRoutine.workouts.count {
                    
                    state.exerciseIndex = nextExerciseIndex
                    state.workoutCardStates[nextExerciseIndex].setIndex = 0
                    state.workoutCardStates[nextExerciseIndex].currentSetNumber = 1
                    state.workoutCardStates[nextExerciseIndex].setProgressAmount = 0
                    
                } else { // 모든 운동 루틴 완료!
                    state.isWorkingout = false
                    // TODO: 운동 완료 화면 이동?
                    // Alert를 한 번 띄우는게 나을듯
                    
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
