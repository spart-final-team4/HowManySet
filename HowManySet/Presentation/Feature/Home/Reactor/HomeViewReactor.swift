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
    /// 현재 루틴 안 운동종목의 인덱스
    var exerciseIndex: Int
    
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
    
    var allSetsCompleted: Bool
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
        case forwardButtonClicked(at: Int)
        /// 운동 중지 버튼 클릭 시
        case workoutPauseButtonClicked
        /// 휴식 시간 설정 버튼 클릭 (1분, 30초, 10초)
        case setRestTime(Int)
        /// 스크롤 뷰 페이지 변경
        case pageChanged(to: Int)
        /// 휴식 중지 버튼 클릭 시
        case restPauseButtonClicked
        /// 운동 종료 버튼 클릭 시
        case stopButtonClicked(with: Bool)
        //        case option
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        
        case setWorkingout(Bool)
        case setWorkoutTime(Int)
        case setResting(Bool)
        case setRestTime(Int)
        /// 휴식 프로그레스 휴식 시간 설정
        case setRestTimeInProgress(Int)
        case workoutTimeUpdating
        case restRemainingSecondsUpdating
        case pauseAndPlayWorkout(Bool)
        case pauseAndPlayRest(Bool)
        case endCurrentWorkout(with: Bool)
        /// 스킵(다음) 버튼 클릭 시 다음 세트로
        case moveToNextSetOrExercise(isRoutineCompleted: Bool)
        /// 현재 운동 카드 업데이트
        case updateWorkoutCardState(WorkoutCardState)
        /// 모든 카드 상태 초기화 (루틴 시작 시)
        case initializeWorkoutCardStates([WorkoutCardState])
        /// 현재 운동종목 모든 세트 완료 시 뷰 삭제
        case setTrueCurrentCardViewCompleted(at: Int)
        /// 페이징 시 currentExerciseIndex 즉시 변경!
        case changeExerciseIndex(Int)
    }
    
    // MARK: - State is a current view state
    struct State {
        /// 전체 루틴 데이터! (운동 진행 중일 시 변화 없음)
        var workoutRoutine: WorkoutRoutine
        /// 현재 루틴의 전체 각 운동의 State
        var workoutCardStates: [WorkoutCardState]
        
        /// 현재 진행 중인 루틴 안 운동의 인덱스
        var currentExerciseIndex: Int
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
        
        var currentExerciseAllSetsCompleted: Bool
    }
    
    let initialState: State
    
    init(saveRecordUseCase: SaveRecordUseCase) {
        self.saveRecordUseCase = saveRecordUseCase
        
        // MARK: - TODO: MOCKDATA -> 실제 데이터로 수정
        // 루틴 선택 시 초기 값 설정
        let initialRoutine = routineMockData
        // 초기 운동 카드 뷰들 state 초기화
        var initialWorkoutCardStates: [WorkoutCardState] = []
        // 현재 루틴의 모든 정보를 workoutCardStates에 저장
        for (i, workout) in initialRoutine.workouts.enumerated() {
            initialWorkoutCardStates.append(WorkoutCardState(
                currentExerciseName: workout.name,
                currentWeight: workout.sets[0].weight,
                currentUnit: workout.sets[0].unit,
                currentReps: workout.sets[0].reps,
                setIndex: 0,
                exerciseIndex: i,
                totalExerciseCount: initialRoutine.workouts.count,
                totalSetCount: workout.sets.count,
                currentExerciseNumber: i + 1,
                currentSetNumber: 1,
                setProgressAmount: 0,
                commentInExercise: workout.comment,
                allSetsCompleted: false
            ))
        }
 
        self.initialState = State(
            workoutRoutine: initialRoutine,
            workoutCardStates: initialWorkoutCardStates,
            currentExerciseIndex: 0, // 첫 운동 인덱스
            
            isWorkingout: false,
            isWorkoutPaused: false,
            workoutTime: 0,
            isResting: false,
            isRestPaused: false,
            restSecondsRemaining: 0,
            restTime: 0,
            date: Date(),
            commentInRoutine: nil,
            currentExerciseAllSetsCompleted: false
        )
    }
    
    // MARK: - Action -> Mutation (Mutate)
    func mutate(action: Action) -> Observable<Mutation> {
        
        print(#function)
        
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
                    exerciseIndex: 0,
                    totalExerciseCount: currentState.workoutRoutine.workouts.count,
                    totalSetCount: workout.sets.count,
                    currentExerciseNumber: i + 1,
                    currentSetNumber: 1,
                    setProgressAmount: 0,
                    commentInExercise: workout.comment,
                    allSetsCompleted: false
                )
            }
            
            // 운동 시간 타이머 설정
            let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .take(until: self.state.map { !$0.isWorkingout }.filter { $0 }) // 운동 끝나면 중단
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
            print("mutate - \(cardIndex)번 인덱스 뷰에서 세트 완료 버튼 클릭!")
            let restTime = currentState.restTime
            let interval = 0.01
            let tickCount = Int(Double(restTime) / interval)
            let restTimer = Observable<Int>.interval(.milliseconds(Int(interval * 1000)), scheduler: MainScheduler.instance)
                .withLatestFrom(self.state) { _, state in state }
                .filter { $0.isResting && !$0.isWorkoutPaused && !$0.isRestPaused }
                .take(tickCount)
                .map { _ in Mutation.restRemainingSecondsUpdating }
            
            return handleWorkoutFlow(cardIndex, restTime, restTimer)
            
        // skip 버튼 클릭 시 - 휴식 스킵 and (다음 세트 or 다음 운동) 진행
        case let .forwardButtonClicked(cardIndex):
            let restTime = 0
            let restTimer: Observable<HomeViewReactor.Mutation> = .empty()
            return handleWorkoutFlow(cardIndex, restTime, restTimer)
            
        case .workoutPauseButtonClicked:
            return .just(.pauseAndPlayWorkout(!currentState.isWorkoutPaused))
            
        case .setRestTime(let newRestTime):
            print("설정된 휴식시간: \(newRestTime)")
            return .concat([
                .just(.setRestTime(newRestTime))
            ])
            
        case .pageChanged(let newPageIndex):
            // 해당 페이지로 운동 인덱스 변경
            return .just(.changeExerciseIndex(newPageIndex))
            
        case .restPauseButtonClicked:
            return .just(.pauseAndPlayRest(!currentState.isRestPaused))
            
        case .stopButtonClicked(let isEnded):
            return .just(.endCurrentWorkout(with: isEnded))
            
        }
    }
    
    
    // MARK: - Mutation -> State (Reduce)
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
            if !state.isResting {
                state.restSecondsRemaining = 0
                state.restStartTime = nil
            }
            print("휴식중? \(state.isResting)")
            
        case let .setRestTime(restTime):
            // 초기화 버튼 클릭 시 0으로 설정
            if restTime == 0 {
                state.restTime = restTime
            } else {
                state.restTime += restTime
            }
            
        case let .setRestTimeInProgress(restTime):
            if currentState.isResting {
                state.restStartTime = restTime
                state.restSecondsRemaining = Float(restTime)
            }
            
        case let .moveToNextSetOrExercise(isRoutineCompleted):
            
            if isRoutineCompleted,
               state.currentExerciseAllSetsCompleted { // 루틴 전체 완료
                
                // 현재 세트 완료 false로 재설정!
                state.currentExerciseAllSetsCompleted = false
                state.isWorkingout = false
                print("루틴 전체 완료 - \(!state.isWorkingout)")
                // MARK: - TODO: 운동 완료 후 기록 저장 등의 추가 작업
                
            } else if state.currentExerciseAllSetsCompleted { // 현재 운동만 완료
                // 현재 세트 완료 false로 재설정!
                state.currentExerciseAllSetsCompleted = false
                print("현재 운동 완료")
            } else { // 다음 세트로
                print("다음 세트로 - \(currentState.workoutCardStates[currentState.currentExerciseIndex].setIndex)")
            }
            
        case let .updateWorkoutCardState(cardState):
            let index = cardState.exerciseIndex
            print("업데이트된 카드 index: \(index)")
            // 현재 카드 상태 업데이트
            state.workoutCardStates[index] = cardState
            print("업데이트된 카드 State \(state.workoutCardStates[index])\n")
            
        case let .initializeWorkoutCardStates(cardStates):
            state.workoutCardStates = cardStates
            state.currentExerciseIndex = 0 // 첫 운동으로 초기화
            
        case .workoutTimeUpdating:
            state.workoutTime += 1
            
        case .restRemainingSecondsUpdating:
            if state.isResting,
               !state.isWorkoutPaused,
               !state.isRestPaused {
                
                state.restSecondsRemaining = max(state.restSecondsRemaining - 0.01, 0)
                if Int(state.restSecondsRemaining) == 0 {
                    state.isResting = false
                }
            }
            
        case let .pauseAndPlayRest(isPaused):
            state.isRestPaused = isPaused
            
        case let .endCurrentWorkout(isEnded):
            if isEnded {
                state.isWorkingout = false
            }
            
        case let .setTrueCurrentCardViewCompleted(cardIndex):
            if currentState.workoutCardStates.indices.contains(cardIndex) {
                state.currentExerciseAllSetsCompleted = true
            }
            
        case let .changeExerciseIndex(newIndex):
            print("현재 운동 인덱스!: \(newIndex)")
            state.currentExerciseIndex = newIndex
        }
        
        return state
    }
}

// MARK: - Private Methods
private extension HomeViewReactor {
    
    func handleWorkoutFlow(
        _ cardIndex: Int,
        _ restTime: Int,
        _ restTimer: Observable<HomeViewReactor.Mutation>) -> Observable<HomeViewReactor.Mutation> {
            
            let nextSetIndex = currentState.workoutCardStates[cardIndex].setIndex + 1
            let currentWorkout = currentState.workoutRoutine.workouts[cardIndex]
            var currentCardState = currentState.workoutCardStates[cardIndex]
            
            // 다음 세트가 있는 경우 (휴식 시작)
            if nextSetIndex < currentCardState.totalSetCount {
                
                let nextSet = currentWorkout.sets[nextSetIndex]
                
                currentCardState.setIndex = nextSetIndex
                currentCardState.currentSetNumber = nextSetIndex + 1
                currentCardState.currentWeight = nextSet.weight
                currentCardState.currentUnit = nextSet.unit
                currentCardState.currentReps = nextSet.reps
                currentCardState.setProgressAmount += 1
                
                /// 변경된 카드 State!
                let updatedCardState = currentCardState
                
                print("현재 세트 정보: \(updatedCardState)")
                
                return .concat([
                    .just(.setResting(restTime > 0)),
                    .just(.setRestTimeInProgress(restTime)),
                    .just(.moveToNextSetOrExercise(isRoutineCompleted: false)),
                    // 카드 정보 업데이트
                    .just(.updateWorkoutCardState(updatedCardState)),
                    restTimer
                ])
            } else { // 현재 운동의 모든 세트 완료, 다음 운동으로 이동 또는 루틴 종료
                
                var nextExerciseIndex = currentState.workoutCardStates.indices.contains(cardIndex) ? cardIndex : 0
                var currentCardState = currentState.workoutCardStates[cardIndex]
                
                // 다음,이전 인덱스가 존재하고 다음,이전 카드 모든 세트 완료 시
                // 뷰 제거시에 나중에 운동완료시 WorkoutCardStates를 쓸 수도 있으니 뷰만 삭제되도록 하였음.
                if currentState.workoutCardStates.indices.contains(cardIndex + 1),
                   !currentState.workoutCardStates[cardIndex + 1].allSetsCompleted {
                    nextExerciseIndex += 1
                } else if  currentState.workoutCardStates.indices.contains(cardIndex - 1),
                           !currentState.workoutCardStates[cardIndex - 1].allSetsCompleted {
                    nextExerciseIndex -= 1
                }
                
                print("🗂️ 현재 index: \(currentState.currentExerciseIndex), 🗂️ 다음 index: \(nextExerciseIndex)")
                
                if nextExerciseIndex < currentState.workoutRoutine.workouts.count {
                    
                    // 마지막 프로그레스바 하나 채우고, 모든 세트 완료 처리
                    currentCardState.setProgressAmount += 1
                    currentCardState.allSetsCompleted = true
                    
                    let updatedCardState = currentCardState
                    
                    // 휴식 관련된 설정 먼저
                    // 현재 카드 뷰 세트 완료 처리
                    // 다음 세트로 이동
                    // 현재 카드뷰 프로그레스 바 풀로 채움
                    // currentExerciseIndex 변경
                    return .concat([
                        .just(.setResting(false)),
                        .just(.setRestTimeInProgress(restTime)),
                        .just(.setTrueCurrentCardViewCompleted(at: cardIndex)),
                        .just(.moveToNextSetOrExercise(isRoutineCompleted: false)),
                        .just(.updateWorkoutCardState(updatedCardState)),
                        .just(.changeExerciseIndex(nextExerciseIndex))
                    ])
                } else { // 모든 운동 루틴 완료
                    
                    let allCompleted = currentState.workoutCardStates
                        .allSatisfy { $0.allSetsCompleted }
                    
                    if allCompleted {
                        // TODO: 운동 완료 화면 이동 또는 Alert 처리
                        print("--- 모든 운동 루틴 완료! ---")
                        return .concat([
                            .just(.setWorkingout(false)),
                            .just(.setResting(false)),
                            .just(.setRestTime(0))
                        ])
                    } else {
                        return .concat([
                            .just(.setResting(false))
                        ])
                    }
                }
            }
        }
}


