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
    
    // 타이머 관리를 위한 Disposable
    private var workoutTimerDisposeBag = DisposeBag()
    private var restTimerDisposeBag = DisposeBag()
    
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
        /// 휴식 시간 설정 버튼 클릭 (1분, 30초, 10초)
        case setRestTime(Int)
        /// 운동 시간 갱신용
        case timerTick
        /// 휴식 시간 갱신용
        case restTimerTick
        /// 스크롤 뷰 페이지 변경
        case pageChanged(to: Int)
        
        //        case stop
        //        case option
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {

        case setWorkingout(Bool)
        case setWorkoutTime(Int)
        case setWorkoutPaused(Bool)
        case setResting(Bool)
        case setRestSecondsRemaining(Float)
        case setRestStartTime(Int?)
        case moveToNextSetOrExercise(newExerciseIndex: Int, newSetIndex: Int, isRoutineCompleted: Bool)
        /// 현재 활성화된 운동 카드 상태만 업데이트
        case updateCurrentWorkoutCardState(WorkoutCardState)
        /// 모든 카드 상태 초기화 (루틴 시작 시)
        case initializeWorkoutCardStates([WorkoutCardState])
        /// 모든 카드 리액터에 전달할 정보
        case updateAllCardStates(newStates: [WorkoutCardState], currentExerciseIndex: Int, isResting: Bool, restSecondsRemaining: Float?, restStartTime: Int?)
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
        /// 프로그레스바에 사용될 현재 휴식 시간 (사용자가 버튼으로 변경 시 즉시 변경 안됨)
        var restSecondsRemaining: Float
        /// 기본 휴식 시간 (사용자가 버튼으로 변경 시 즉시 변경)
        var restTime: Int
        /// 휴식이 시작될 때의 값 (프로그레스바 용)
        var restStartTime: Int?
        
        var date: Date
        var commentInRoutine: String?
        
        /// 운동 카드들의 UI 상태 관리
        var pagingCardViewReactors: [HomePagingCardViewReactor]
    }
    
    let initialState: State
    
    
    init(saveRecordUseCase: SaveRecordUseCase) {
        self.saveRecordUseCase = saveRecordUseCase
        
        // 루틴 선택 시 초기 값 설정
        let initialRoutine = routineMockData
        
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
        
        // HomePagingCardViewReactor 인스턴스 초기화
        let initialPagingCardViewReactors = initialWorkoutCardStates.map { cardState in
            // HomePagingCardViewReactor는 자신의 초기 상태(운동 정보)만 가짐
            // 휴식 관련 정보는 HomeViewReactor가 직접 주입
            HomePagingCardViewReactor(initialCardState: cardState)
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
            restTime: initialRoutine.restTime,
            date: Date(),
            commentInRoutine: nil,
            pagingCardViewReactors: initialPagingCardViewReactors
        )
    }
    
    // MARK: - Mutate(Action -> Mutation)
    func mutate(action: Action) -> Observable<Mutation> {
        
        print(#function)
        
        var currentWorkoutCardStates = currentState.workoutCardStates
        var currentExerciseIndex = currentState.exerciseIndex
        var currentCardState = currentWorkoutCardStates[currentExerciseIndex]
        let currentWorkout = currentState.workoutRoutine.workouts[currentExerciseIndex]
        
        switch action {
            
        case .routineSelected:
            startWorkoutTimer()
            // 모든 카드 뷰의 상태를 초기화하고, 첫 운동의 첫 세트를 보여줌
            let updatedCardStates = currentState.workoutRoutine.workouts.enumerated().map { (idx, workout) in
                let firstSet = workout.sets.first!
                return WorkoutCardState(
                    currentExerciseName: workout.name,
                    currentWeight: firstSet.weight,
                    currentUnit: firstSet.unit,
                    currentReps: firstSet.reps,
                    setIndex: 0,
                    totalExerciseCount: currentState.workoutRoutine.workouts.count,
                    totalSetCount: workout.sets.count,
                    currentExerciseNumber: idx + 1,
                    currentSetNumber: 1,
                    setProgressAmount: 0,
                    commentInExercise: workout.comment
                )
            }
            return .concat([
                .just(.setWorkingout(true)),
                .just(.initializeWorkoutCardStates(updatedCardStates)),
                .just(.updateAllCardStates(
                    newStates: updatedCardStates,
                    currentExerciseIndex: currentState.exerciseIndex,
                    isResting: false,
                    restSecondsRemaining: 0,
                    restStartTime: nil))
            ])
            
        // 세트 완료 버튼 클릭 시 로직
        case .setCompleteButtonClicked:
            // 현재 세트 완료 처리
            currentCardState.setProgressAmount += 1
            currentWorkoutCardStates[currentExerciseIndex] = currentCardState
            
            let nextSetIndex = currentCardState.setIndex + 1
            
            if nextSetIndex < currentWorkout.sets.count { // 다음 세트가 있는 경우 (휴식 시작)
                stopRestTimer() // 이전 타이머가 있다면 중지
                startRestTimer()
                return .concat([
                    .just(.setResting(true)),
                    .just(.setRestStartTime(currentState.restTime)), // 루틴의 기본 휴식 시간으로 설정
                    .just(.setRestSecondsRemaining(Float(currentState.restTime))),
                    .just(.updateAllCardStates(
                        newStates: currentWorkoutCardStates,
                        currentExerciseIndex: currentExerciseIndex,
                        isResting: true,
                        restSecondsRemaining: Float(currentState.restTime),
                        restStartTime: currentState.restTime))
                ])
            } else { // 현재 운동의 모든 세트 완료, 다음 운동으로 이동 또는 루틴 종료
                let nextExerciseIndex = currentExerciseIndex + 1
                if nextExerciseIndex < currentState.workoutRoutine.workouts.count {
                    // 다음 운동의 첫 세트로 이동
                    let nextWorkout = currentState.workoutRoutine.workouts[nextExerciseIndex]
                    let nextCardState = WorkoutCardState(
                        currentExerciseName: nextWorkout.name,
                        currentWeight: nextWorkout.sets.first!.weight,
                        currentUnit: nextWorkout.sets.first!.unit,
                        currentReps: nextWorkout.sets.first!.reps,
                        setIndex: 0,
                        totalExerciseCount: currentState.workoutRoutine.workouts.count,
                        totalSetCount: nextWorkout.sets.count,
                        currentExerciseNumber: nextExerciseIndex + 1,
                        currentSetNumber: 1,
                        setProgressAmount: 0,
                        commentInExercise: nextWorkout.comment
                    )
                    // 다음 운동 카드 상태 업데이트
                    currentWorkoutCardStates[nextExerciseIndex] = nextCardState
                    
                    return .concat([
                        .just(.setResting(false)), // 휴식 종료 (다음 운동으로 바로 이동)
                        .just(.setRestSecondsRemaining(0)),
                        .just(.setRestStartTime(nil)),
                        .just(.moveToNextSetOrExercise(newExerciseIndex: nextExerciseIndex, newSetIndex: 0, isRoutineCompleted: false)),
                        .just(.updateAllCardStates(newStates: currentWorkoutCardStates, currentExerciseIndex: nextExerciseIndex, isResting: false, restSecondsRemaining: 0, restStartTime: nil))
                    ])
                } else { // 모든 운동 루틴 완료
                    stopWorkoutTimer()
                    stopRestTimer()
                    // TODO: 운동 완료 화면 이동 또는 Alert 처리
                    print("--- 모든 운동 루틴 완료! ---")
                    return .concat([
                        .just(.setWorkingout(false)),
                        .just(.setResting(false)),
                        .just(.setRestSecondsRemaining(0)),
                        .just(.setRestStartTime(nil))
                    ])
                }
            }
            
        case .forwardButtonClicked: // 휴식 스킵 또는 다음 세트 진행
            stopRestTimer()
            let nextSetIndex = currentCardState.setIndex + 1
            if nextSetIndex < currentWorkout.sets.count { // 다음 세트가 있는 경우
                return .concat([
                    .just(.setResting(false)),
                    .just(.setRestSecondsRemaining(0)),
                    .just(.setRestStartTime(nil)),
                    .just(.moveToNextSetOrExercise(newExerciseIndex: currentExerciseIndex, newSetIndex: nextSetIndex, isRoutineCompleted: false))
                ])
            } else { // 현재 운동의 마지막 세트에서 건너뛰는 경우 (다음 운동으로 이동 또는 루틴 종료)
                let nextExerciseIndex = currentExerciseIndex + 1
                if nextExerciseIndex < currentState.workoutRoutine.workouts.count {
                    return .concat([
                        .just(.setResting(false)),
                        .just(.setRestSecondsRemaining(0)),
                        .just(.setRestStartTime(nil)),
                        .just(.moveToNextSetOrExercise(newExerciseIndex: nextExerciseIndex, newSetIndex: 0, isRoutineCompleted: false))
                    ])
                } else { // 모든 운동 루틴 완료
                    stopWorkoutTimer()
                    stopRestTimer()
                    // TODO: 운동 완료 화면 이동 또는 Alert 처리
                    print("--- 모든 운동 루틴 완료! (Forward Button) ---")
                    return .concat([
                        .just(.setWorkingout(false)),
                        .just(.setResting(false)),
                        .just(.setRestSecondsRemaining(0)),
                        .just(.setRestStartTime(nil))
                    ])
                }
            }
        case .pauseButtonClicked:
            if currentState.isWorkoutPaused {
                stopWorkoutTimer()
                stopRestTimer()
            } else {
                startWorkoutTimer()
                if currentState.isResting { startRestTimer() }
            }
            return .just(.setWorkoutPaused(!currentState.isWorkoutPaused))
            
            
        case .setRestTime(let newRestTime):
            return .concat([
                .just(.setRestStartTime(newRestTime)),
                .just(.setRestSecondsRemaining(Float(newRestTime)))
            ])
            
            
        case .timerTick: // 전체 운동 시간 갱신
            guard !currentState.isWorkoutPaused else { return .empty() }
            return .just(.setWorkoutTime(currentState.workoutTime + 1))
            
        case .restTimerTick: // 휴식 시간 감소 (0.01초마다)
            guard !currentState.isWorkoutPaused else { return .empty() }
            guard currentState.isResting else { return .empty() }
            
            let newRemaining = max(currentState.restSecondsRemaining - 0.01, 0)
            if newRemaining <= 0 { // 휴식 시간 종료
                stopRestTimer()
                // 휴식 종료 후 다음 세트로 자동 이동
                let nextSetIndex = currentCardState.setIndex + 1
                
                if nextSetIndex < currentWorkout.sets.count {
                    // 다음 세트가 있는 경우, 상태 업데이트를 포함하여 다음 세트로 이동
                    return .concat([
                        .just(.setResting(false)),
                        .just(.setRestSecondsRemaining(0)),
                        .just(.setRestStartTime(nil)),
                        .just(.moveToNextSetOrExercise(newExerciseIndex: currentExerciseIndex, newSetIndex: nextSetIndex, isRoutineCompleted: false))
                    ])
                } else { // 현재 운동의 모든 세트 완료, 다음 운동으로 이동 또는 루틴 종료
                    let nextExerciseIndex = currentExerciseIndex + 1
                    if nextExerciseIndex < currentState.workoutRoutine.workouts.count {
                        return .concat([
                            .just(.setResting(false)),
                            .just(.setRestSecondsRemaining(0)),
                            .just(.setRestStartTime(nil)),
                            .just(.moveToNextSetOrExercise(newExerciseIndex: nextExerciseIndex, newSetIndex: 0, isRoutineCompleted: false))
                        ])
                    } else { // 모든 운동 루틴 완료
                        stopWorkoutTimer()
                        // TODO: 운동 완료 화면 이동 또는 Alert 처리
                        print("--- 모든 운동 루틴 완료! (Rest Timer Ended) ---")
                        return .concat([
                            .just(.setWorkingout(false)),
                            .just(.setResting(false)),
                            .just(.setRestSecondsRemaining(0)),
                            .just(.setRestStartTime(nil))
                        ])
                    }
                }
            } else {
                return .just(.setRestSecondsRemaining(newRemaining))
            }
            
        case .pageChanged(let newPageIndex):
            // 페이지 변경 시 휴식 중이었다면 휴식 종료 및 타이머 중지
            stopRestTimer()
            // 해당 페이지의 운동으로 이동
            return .concat([
                .just(.setResting(false)),
                .just(.setRestSecondsRemaining(0)),
                .just(.setRestStartTime(nil)),
                .just(.moveToNextSetOrExercise(newExerciseIndex: newPageIndex, newSetIndex: 0, isRoutineCompleted: false))
            ])
        }
    }
    
    
    
    // MARK: - Reduce(Mutation -> State)
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
            
        case let .setWorkingout(isWorkingout):
            newState.isWorkingout = isWorkingout
            
        case let .setWorkoutTime(time):
            newState.workoutTime = time
            
        case let .setWorkoutPaused(isPaused):
            newState.isWorkoutPaused = isPaused
            
        case let .setResting(isResting):
            newState.isResting = isResting
            // 휴식 상태가 해제되면 휴식 시간 관련 정보 초기화
            if !isResting {
                newState.restSecondsRemaining = 0
                newState.restStartTime = nil
            }
            
        case let .setRestSecondsRemaining(remaining):
            newState.restSecondsRemaining = remaining
            
        case let .setRestStartTime(startTime):
            newState.restStartTime = startTime
            
        case let .moveToNextSetOrExercise(newExerciseIndex, newSetIndex, isRoutineCompleted):
            if isRoutineCompleted { // 루틴 전체 완료
                newState.isWorkingout = false
                // TODO: 운동 완료 후 기록 저장 등의 추가 작업
            } else {
                newState.exerciseIndex = newExerciseIndex // 현재 운동 인덱스 업데이트
                
                // 현재 운동의 카드 상태 업데이트
                var currentCardState = newState.workoutCardStates[newExerciseIndex]
                let workout = newState.workoutRoutine.workouts[newExerciseIndex]
                
                if newSetIndex == 0 { // 새로운 운동으로 넘어갈 때 (첫 세트로 초기화)
                    currentCardState.setIndex = 0
                    currentCardState.currentSetNumber = 1
                    currentCardState.setProgressAmount = 0
                    currentCardState.currentWeight = workout.sets.first?.weight ?? 0
                    currentCardState.currentReps = workout.sets.first?.reps ?? 0
                    currentCardState.currentUnit = workout.sets.first?.unit ?? "kg"
                } else { // 다음 세트로 넘어갈 때
                    let nextSet = workout.sets[newSetIndex]
                    currentCardState.setIndex = newSetIndex
                    currentCardState.currentSetNumber = newSetIndex + 1
                    currentCardState.setProgressAmount = newSetIndex / workout.sets.count // 진행률 업데이트
                    currentCardState.currentWeight = nextSet.weight
                    currentCardState.currentReps = nextSet.reps
                    currentCardState.currentUnit = nextSet.unit
                }
                newState.workoutCardStates[newExerciseIndex] = currentCardState
                
                // 모든 카드 뷰 리액터에게 최신 상태 전달
                newState = updatePagingCardReactors(newState)
            }
        case let .updateCurrentWorkoutCardState(cardState):
            // 현재 활성화된 카드 상태만 업데이트
            newState.workoutCardStates[newState.exerciseIndex] = cardState
            newState = updatePagingCardReactors(newState)
            
        case let .initializeWorkoutCardStates(cardStates):
            newState.workoutCardStates = cardStates
            newState.exerciseIndex = 0 // 첫 운동으로 초기화
            newState = updatePagingCardReactors(newState)
            
        case let .updateAllCardStates(newStates, currentExerciseIndex, isResting, restSecondsRemaining, restStartTime):
            // 이 뮤테이션은 mutate에서 명시적으로 호출되어 reduce에서 workoutCardStates를 업데이트하고,
            // 모든 pagingCardViewReactors에 최신 상태를 전달하는 역할
            newState.workoutCardStates = newStates
            newState.isResting = isResting
            newState.restSecondsRemaining = restSecondsRemaining ?? 0
            newState.restStartTime = restStartTime
            newState.exerciseIndex = currentExerciseIndex // 현재 운동 인덱스도 함께 업데이트
            newState = updatePagingCardReactors(newState)
        }
        
        
        return state
    }
}

// MARK: - Private Methods
private extension HomeViewReactor {
    
    /// HomePagingCardViewReactor의 action 스트림을 통해 상태를 주입
    func updatePagingCardReactors(_ state: State) -> State {
        var newState = state
        
        for (index, reactor) in newState.pagingCardViewReactors.enumerated() {
            let cardState = newState.workoutCardStates[index]
            let isCurrentCard = (index == newState.exerciseIndex)
            
            // 현재 활성화된 카드 뷰에게만 HomeViewReactor의 휴식 상태를 전달
            let currentRestRemaining = isCurrentCard ? newState.restSecondsRemaining : 0
            let currentRestStart = isCurrentCard ? newState.restStartTime : nil
            let currentIsResting = isCurrentCard && newState.isResting
            
            reactor.action.onNext(.updateCardState(cardState))
        }
        return newState
    }
    
    // MARK: - Timer
    func startWorkoutTimer() {
        workoutTimerDisposeBag = DisposeBag() // 기존 타이머 중지
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .filter { [weak self] _ in !(self?.currentState.isWorkoutPaused ?? true) } // 일시정지 상태가 아닐 때만 틱
            .map { _ in .timerTick }
            .bind(to: action)
            .disposed(by: workoutTimerDisposeBag)
    }
    
    func stopWorkoutTimer() {
        workoutTimerDisposeBag = DisposeBag()
    }
    
    func startRestTimer() {
        restTimerDisposeBag = DisposeBag() // 기존 타이머 중지
        Observable<Int>.interval(.milliseconds(10), scheduler: MainScheduler.instance) // 0.01초마다 틱
            .filter { [weak self] _ in !(self?.currentState.isWorkoutPaused ?? true) } // 일시정지 상태가 아닐 때만 틱
            .take(until: { [weak self] _ in (self?.currentState.restSecondsRemaining ?? 0) <= 0 }) // 남은 시간이 0이 되면 중지
            .map { _ in .restTimerTick }
            .bind(to: action)
            .disposed(by: restTimerDisposeBag)
    }
    
    func stopRestTimer() {
        restTimerDisposeBag = DisposeBag()
    }
}

