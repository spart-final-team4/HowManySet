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
struct WorkoutCardState {
    
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
        case setCompleteButtonClicked(at: Int)
        /// 휴식 스킵? 다음 세트?
        case forwardButtonClicked
        /// 운동 중지 버튼 클릭 시
        case pauseButtonClicked
        /// 휴식 시간 설정 버튼 클릭 (1분, 30초, 10초)
        case setRestTime(Int)
        /// 스크롤 뷰 페이지 변경
        case pageChanged(to: Int)
        
        //        case stop
        //        case option
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        
        case setWorkingout(Bool)
        case setWorkoutTime(Int)
        case setResting(Bool)
        case setRestStartTime(Int?)
        case setRestTime(Int)
        case workoutTimeUpdating
        case restRemainingSecondsUpdating
        case pauseAndPlayWorkout(Bool)
        /// 스킵(다음) 버튼 클릭 시 다음 세트로
        case moveToNextSetOrExercise(newExerciseIndex: Int, newSetIndex: Int, isRoutineCompleted: Bool)
        /// 현재 운동 카드 업데이트
        case updateWorkoutCardState(WorkoutCardState)
        /// 모든 카드 상태 초기화 (루틴 시작 시)
        case initializeWorkoutCardStates([WorkoutCardState])
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
        
        var isResting: Bool
        var isRestPaused: Bool
        /// 프로그레스바에 사용될 현재 휴식 시간
        var restSecondsRemaining: Float
        /// 기본 휴식 시간
        var restTime: Int
        /// 휴식이 시작될 때의 값 (프로그레스바 용)
        var restStartTime: Int?
        
        var date: Date
        var commentInRoutine: String?
        
        var currentExerciseCompleted: Bool
    }
    
    let initialState: State
    
    
    init(saveRecordUseCase: SaveRecordUseCase) {
        self.saveRecordUseCase = saveRecordUseCase
        
        // TODO: MOCKDATA -> 실제 데이터로 수정
        // 루틴 선택 시 초기 값 설정
        let initialRoutine = routineMockData
        
        // 초기 운동 카드 뷰들 state 초기화
        var initialWorkoutCardStates: [WorkoutCardState] = []
        
        // 현재 루틴의 모든 정보를 workoutCardStates에 저장
        for (i, workout) in initialRoutine.workouts.enumerated() {
            let firstSet = workout.sets.first!
            initialWorkoutCardStates.append(WorkoutCardState(
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
            workoutCardStates: initialWorkoutCardStates,
            exerciseIndex: 0, // 첫 운동 인덱스
            
            isWorkingout: false,
            isWorkoutPaused: false,
            workoutTime: 0,
            isResting: false,
            isRestPaused: false,
            restSecondsRemaining: 0,
            restTime: 0,
            date: Date(),
            commentInRoutine: nil,
            currentExerciseCompleted: false
        )
    }
    
    // MARK: - Mutate(Action -> Mutation)
    func mutate(action: Action) -> Observable<Mutation> {
        
        print(#function)
        
        /// 현재 루틴의 모든 운동카드들의 State
        var currentWorkoutCardStates = currentState.workoutCardStates
        /// 현재 운동종목 인덱스
        let currentExerciseIndex = currentState.exerciseIndex
        /// 현재 운동종목 카드의 State
        var currentCardState = currentWorkoutCardStates[currentExerciseIndex]
        /// 현재 운동종목의 정보
        let currentWorkout = currentState.workoutRoutine.workouts[currentExerciseIndex]
        
        switch action {
        
        // 초기 루틴 선택 시
        case .routineSelected:
            // 모든 카드 뷰의 상태를 초기화하고, 첫 운동의 첫 세트를 보여줌
            let updatedCardStates = currentState.workoutRoutine.workouts.enumerated().map { (i, workout) in
                let firstSet = workout.sets.first!
                return WorkoutCardState(
                    currentExerciseName: workout.name,
                    currentWeight: firstSet.weight,
                    currentUnit: firstSet.unit,
                    currentReps: firstSet.reps,
                    setIndex: 0,
                    totalExerciseCount: currentState.workoutRoutine.workouts.count,
                    totalSetCount: workout.sets.count,
                    currentExerciseNumber: i + 1,
                    currentSetNumber: 1,
                    setProgressAmount: 0,
                    commentInExercise: workout.comment
                )
            }
            
            // 운동 시간 타이머 설정
            let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .withLatestFrom(self.state.map{ $0.isWorkoutPaused }) { _, isPaused in return isPaused }
                .filter { !$0 }
                .map { _ in Mutation.workoutTimeUpdating }
            
            return .concat([
                .just(.setWorkingout(true)),
                timer,
                .just(.initializeWorkoutCardStates(updatedCardStates)),
                
            ])
            
        // 세트 완료 버튼 클릭 시 로직
        case let .setCompleteButtonClicked(cardIndex):
            
            var currentCardState = currentWorkoutCardStates[cardIndex]

            print("mutate - 세트 완료 버튼 클릭!")
            let restTime = currentState.restTime
            let interval = 0.01
            let tickCount = Int(Double(restTime) / interval)
            let restTimer = Observable<Int>.interval(.milliseconds(Int(interval * 1000)), scheduler: MainScheduler.instance)
                .take(tickCount)
                .map { _ in Mutation.restRemainingSecondsUpdating }
            
            let nextSetIndex = currentCardState.setIndex + 1
            
//            // 현재 세트 완료 처리
//            currentCardState.setProgressAmount += 1
//            currentCardState.currentSetNumber += 1
//            currentCardState.setIndex += 1
            
            // 현재 cardState에 적용
//            currentWorkoutCardStates[currentExerciseIndex] = updatedCardState
                        
            // 다음 세트가 있는 경우 (휴식 시작)
            if nextSetIndex < currentCardState.totalSetCount {
                
                currentCardState.setIndex = nextSetIndex
                currentCardState.currentSetNumber = nextSetIndex + 1
                currentCardState.setProgressAmount += 1
                
                print("현재 세트 정보: \(currentCardState)")
                
                return .concat([
                    .just(.setResting(true)),
                    .just(.setRestStartTime(currentState.restTime)),
                    // 카드 정보 업데이트
                    .just(.updateWorkoutCardState(currentCardState)),
                    restTimer
                ])
            } else { // 현재 운동의 모든 세트 완료, 다음 운동으로 이동 또는 루틴 종료
                
                let nextExerciseIndex = currentExerciseIndex + 1
                if nextExerciseIndex < currentState.workoutRoutine.workouts.count {
        
                    return .concat([
                        .just(.setResting(false)), // 휴식 종료 (다음 운동으로 바로 이동)
                        .just(.setRestStartTime(nil)),
                        .just(.moveToNextSetOrExercise(newExerciseIndex: nextExerciseIndex, newSetIndex: 0, isRoutineCompleted: false)),
                    ])
                } else { // 모든 운동 루틴 완료
                    // TODO: 운동 완료 화면 이동 또는 Alert 처리
                    print("--- 모든 운동 루틴 완료! ---")
                    return .concat([
                        .just(.setWorkingout(false)),
                        .just(.setResting(false)),
                        .just(.setRestStartTime(nil))
                    ])
                }
            }
            
        // 휴식 스킵 or (다음 세트 or 다음 운동) 진행
        case .forwardButtonClicked:
            let nextSetIndex = currentCardState.setIndex + 1
            if nextSetIndex < currentWorkout.sets.count { // 다음 세트가 있는 경우
                return .concat([
                    .just(.setResting(false)),
                    .just(.setRestStartTime(nil)),
                    .just(.moveToNextSetOrExercise(newExerciseIndex: currentExerciseIndex, newSetIndex: nextSetIndex, isRoutineCompleted: false))
                ])
            } else { // 현재 운동의 마지막 세트에서 건너뛰는 경우 (다음 운동으로 이동 또는 루틴 종료)
                let nextExerciseIndex = currentExerciseIndex + 1
                if nextExerciseIndex < currentState.workoutRoutine.workouts.count {
                    return .concat([
                        .just(.setResting(false)),
                        .just(.setRestStartTime(nil)),
                        .just(.moveToNextSetOrExercise(newExerciseIndex: nextExerciseIndex, newSetIndex: 0, isRoutineCompleted: false))
                    ])
                } else { // 모든 운동 루틴 완료
                    // TODO: 운동 완료 화면 이동 또는 Alert 처리
                    
                    print("--- 모든 운동 루틴 완료! (Forward Button) ---")
                    return .concat([
                        .just(.setWorkingout(false)),
                        .just(.setResting(false)),
                        .just(.setRestStartTime(nil))
                    ])
                }
            }
        case .pauseButtonClicked:
            // 중지 버튼 클릭 시 - 이 시점에는 isWorkingoutPaused가 변경 안되어 있음
            //            if currentState.isWorkoutPaused {
            //                startWorkoutTimer()
            //                if currentState.isResting { startRestTimer() }
            //            } else {
            //                stopWorkoutTimer()
            //                stopRestTimer()
            //            }
            return .just(.pauseAndPlayWorkout(!currentState.isWorkoutPaused))
            
            
        case .setRestTime(let newRestTime):
            return .concat([
                .just(.setRestStartTime(newRestTime)),
                .just(.setRestTime(newRestTime))
            ])
            
        case .pageChanged(let newPageIndex):
            // 해당 페이지의 운동으로 이동
            return .concat([
                .just(.moveToNextSetOrExercise(newExerciseIndex: newPageIndex, newSetIndex: 0, isRoutineCompleted: false))
            ])
        }
    }
    
    // MARK: - Reduce(Mutation -> State)
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {
            
        case let .setWorkingout(isWorkingout):
            state.isWorkingout = isWorkingout
            
        case let .setWorkoutTime(time):
            state.workoutTime = time
            
        case let .pauseAndPlayWorkout(isPaused):
            state.isWorkoutPaused = isPaused
            
        case let .setResting(isResting):
            state.isResting = isResting
            // 휴식 상태가 해제되면 휴식 시간 관련 정보 초기화
            if !isResting {
                state.restSecondsRemaining = 0
                state.restStartTime = nil
            }
            
        case let .setRestStartTime(startTime):
            state.restStartTime = startTime
            
        case let .setRestTime(restTime):
            // 초기화 버튼 클릭 시 0으로 설정
            if restTime == 0 {
                state.restTime = restTime
            } else {
                state.restTime += restTime
            }
            
        case let .moveToNextSetOrExercise(newExerciseIndex, newSetIndex, isRoutineCompleted):
            if isRoutineCompleted { // 루틴 전체 완료
                state.isWorkingout = false
                // MARK: - TODO: 운동 완료 후 기록 저장 등의 추가 작업
                
            } else {
                
                state.exerciseIndex = newExerciseIndex // 현재 운동 인덱스 업데이트
                
                // 현재 운동의 카드 상태 업데이트
                var currentCardState = state.workoutCardStates[newExerciseIndex]
                let workout = state.workoutRoutine.workouts[newExerciseIndex]
                
                if newSetIndex == 0 { // 새로운 운동으로 넘어갈 때 (첫 세트로 초기화)
                    state.currentExerciseCompleted = true

                    currentCardState.setIndex = 0
                    currentCardState.currentSetNumber = 1
                    currentCardState.setProgressAmount = 0
                    currentCardState.currentWeight = workout.sets.first?.weight ?? 0
                    currentCardState.currentReps = workout.sets.first?.reps ?? 0
                    currentCardState.currentUnit = workout.sets.first?.unit ?? "kg"
                    
                    state.currentExerciseCompleted = false

                } else { // 다음 세트로 넘어갈 때
                    let nextSet = workout.sets[newSetIndex]
                    currentCardState.setIndex = newSetIndex
                    currentCardState.currentSetNumber = newSetIndex + 1
                    currentCardState.setProgressAmount = newSetIndex / workout.sets.count // 진행률 업데이트
                    currentCardState.currentWeight = nextSet.weight
                    currentCardState.currentReps = nextSet.reps
                    currentCardState.currentUnit = nextSet.unit
                }
                state.workoutCardStates[newExerciseIndex] = currentCardState
             
            }
            
        case let .updateWorkoutCardState(cardState):
            let index = cardState.currentExerciseNumber - 1
            print("보내는 index: \(index)")
            // 현재 카드 상태 업데이트
            state.workoutCardStates[index] = cardState
            
        case let .initializeWorkoutCardStates(cardStates):
            state.workoutCardStates = cardStates
            state.exerciseIndex = 0 // 첫 운동으로 초기화
            
        case .workoutTimeUpdating:
            state.workoutTime += 1
            
        case .restRemainingSecondsUpdating:
            if state.isResting {
                state.restSecondsRemaining = max(state.restSecondsRemaining - 0.01, 0)
            }
        }
        
        return state
    }
}


