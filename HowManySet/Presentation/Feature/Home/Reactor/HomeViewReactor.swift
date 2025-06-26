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
struct WorkoutCardState: Codable {
    // UI에 직접 표시될 값들 (Reactor에서 미리 계산하여 제공)
    var currentExerciseName: String
    var currentWeight: Double
    var currentUnit: String
    var currentReps: Int
    /// 운동 세트 전체 정보
    var setInfo: [WorkoutSet]
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
    var memoInExercise: String?
    var allSetsCompleted: Bool
    
    /// 현재 세트의 무게
    var currentWeightForSave: Double { setInfo[setIndex].weight }
    /// 현재 세트의 단위
    var currentUnitForSave: String { setInfo[setIndex].unit }
    /// 현재 세트의 반복수
    var currentRepsForSave: Int { setInfo[setIndex].reps }
}

/// 운동 완료 UI에 보여질 운동 요약 통계 정보
struct WorkoutSummary: Codable {
    let routineName: String
    let date: Date
    let routineDidProgress: Float
    let totalTime: Int
    let exerciseDidCount: Int
    let setDidCount: Int
    let routineMemo: String?
}

/// 운동 편집 시 보낼 데이터 형식
struct WorkoutStateForEdit: Equatable, Codable {
    var currentRoutine: WorkoutRoutine
    var currentExcerciseName: String
    var currentUnit: String
    var currentWeightSet: [[String]]
}

final class HomeViewReactor: Reactor {
    
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
        case setRestTime(Float)
        /// 스크롤 뷰 페이지 변경
        case pageChanged(to: Int)
        /// 휴식 중지 버튼 클릭 시
        case restPauseButtonClicked
        /// 운동 종료 버튼 클릭 시
        case stopButtonClicked(isEnded: Bool)
        /// 카드의 운동 옵션 버튼 클릭으로 editAndMemoView present시
        case editAndMemoViewPresented(at: Int)
        /// MemoTextView의 메모로 업데이트
        case updateCurrentExerciseMemo(with: String)
        /// 무게, 횟수 컨테이너 버튼 클릭 시
        case editExerciseViewPresented(at: Int, isPresented: Bool)
        /// 운동 완료 화면에서 확인 시 다시 저장 (루틴 메모 작성했을시에만)
        case confirmButtonClickedForSaving(newMemo: String?)
        case updateCurrentRoutineMemo(with: String)
        /// 운동 완료 후 카드 삭제 완료
        case cardDeleteAnimationCompleted(oldIndex: Int, nextIndex: Int)
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setWorkingout(Bool)
        case setWorkoutTime(Int)
        case setResting(Bool)
        /// 하단 휴식 버튼 누를 시 동작
        case setRestTime(Float)
        /// 휴식 프로그레스 휴식 시간 설정
        case setRestTimeDataAtProgressBar(Float)
        case workoutTimeUpdating
        case restRemainingSecondsUpdating
        case pauseAndPlayWorkout(Bool)
        case pauseRest(Bool)
        /// 운동 데이터 업데이트, 운동 종료시 처리 포함
        case manageWorkoutData(isEnded: Bool)
        /// 스킵(다음) 버튼 클릭 시 분기처리 및 완료항목 업데이트
        case manageDataIfForwarded(
            isRoutineCompleted: Bool,
            isCurrentExerciseCompleted: Bool
        )
        /// 현재 운동 카드 업데이트
        case updateWorkoutCardState(
            updatedCardState: WorkoutCardState,
            oldCardState: WorkoutCardState? = nil,
            oldCardIndex: Int? = nil)
        /// 모든 카드 상태 초기화 (루틴 시작 시)
        case initializeWorkoutCardStates([WorkoutCardState])
        /// 현재 운동종목 모든 세트 완료 시 뷰 삭제
        case setTrueCurrentCardViewCompleted(at: Int)
        /// 페이징 시 currentExerciseIndex 즉시 변경!
        case changeExerciseIndex(Int)
        // 편집, 메모 모달창 관련
        case setEditAndMemoViewPresented(Bool)
        case updateExerciseMemo(with: String?)
        /// 휴식 타이머 중단
        case stopRestTimer(Bool)
        /// 운동 완료 시 usecase이용해서 데이터 저장
        case saveWorkoutData
        case setEditExerciseViewPresented(Bool)
        /// 운동 편집 시 Edit용 데이터로 변형
        case convertToEditData(at: Int)
        case updateRoutineMemo(with: String?)
        /// updatingIndex 설정
        case setUpdatingIndex(Int)
        // 백그라운드 관련
        case setWorkoutStartDate(Date?)
        case setAccumulatedWorkoutTime(TimeInterval)
    }
    
    // MARK: - State is a current view state
    struct State: Codable {
        /// 전체 루틴 데이터
        var workoutRoutine: WorkoutRoutine
        /// 현재 루틴의 전체 각 운동의 State
        var workoutCardStates: [WorkoutCardState]
        /// 현재 홈 화면에서 유저한테 보여지는 운동카드의 index
        var currentExerciseIndex: Int
        /// 현재 세트 완료 등 상호작용을 하고 있는 운동카드의 index
        var updatingIndex: Int
        /// 운동 시작 시 운동 중
        var isWorkingout: Bool
        /// 운동 중지 시
        var isWorkoutPaused: Bool
        var workoutTime: Int
        var isResting: Bool
        var isRestPaused: Bool
        /// 현재 남은 휴식 시간
        var restSecondsRemaining: Float
        /// 기본 휴식 시간
        var restTime: Float
        /// 휴식이 시작될 때의 값 (프로그레스바 용)
        var restStartTime: Float?
        var date: Date
        var memoInRoutine: String?
        var currentExerciseAllSetsCompleted: Bool
        var isEditAndMemoViewPresented: Bool
        var isEditExerciseViewPresented: Bool
        var isRestTimerStopped: Bool
        // 기록 관련
        /// 저장되는 운동 기록 정보
        var workoutRecord: WorkoutRecord
        /// UI에 보여질 운동 요약 정보
        var workoutSummary: WorkoutSummary
        var totalExerciseCount: Int
        var didExerciseCount: Int
        var totalSetCountInRoutine: Int
        var didSetCount: Int
        /// 현재 사용자 uid
        var uid: String?
        var workoutStateForEdit: WorkoutStateForEdit?
        // 백그라운드 용
        /// 운동 시작 시각
        var workoutStartDate: Date?
        /// 총 누적된 시간
        var accumulatedWorkoutTime: TimeInterval
    }
    
    // initialState 주입으로 변경
    let initialState: State
    
    private let saveRecordUseCase: SaveRecordUseCase
    private let fsSaveRecordUseCase: FSSaveRecordUseCase
//    private let deleteRecordUseCase: DeleteRecordUseCaseProtocol
//    private let fsDeleteRecordUseCase: FSDeleteRecordUseCase
    private let fetchRoutineUseCase: FetchRoutineUseCase
    private let fsFetchRoutineUseCase: FSFetchRoutineUseCase
    private let updateWorkoutUseCase: UpdateWorkoutUseCase
    // TODO: 추후에 FSUpdateWorkoutUseCase 적용
    private let fsUpdateRoutineUseCase: FSUpdateRoutineUseCase
    
    // TODO: 추후에 실제 데이터 Fetch로 변경
    private let routineMockData = WorkoutRoutine.mockData[0]
    private let recordMockData = WorkoutRecord.mockData[0]
    
    init(
        saveRecordUseCase: SaveRecordUseCase,
        fsSaveRecordUseCase: FSSaveRecordUseCase,
        fetchRoutineUseCase: FetchRoutineUseCase,
        fsFetchRoutineUseCase: FSFetchRoutineUseCase,
        updateWorkoutUseCase: UpdateWorkoutUseCase,
        fsUpdateRoutineUseCase: FSUpdateRoutineUseCase,
        initialState: State
    ) {
        self.saveRecordUseCase = saveRecordUseCase
        self.fsSaveRecordUseCase = fsSaveRecordUseCase
        self.fetchRoutineUseCase = fetchRoutineUseCase
        self.fsFetchRoutineUseCase = fsFetchRoutineUseCase
        self.updateWorkoutUseCase = updateWorkoutUseCase
        self.fsUpdateRoutineUseCase = fsUpdateRoutineUseCase
        self.initialState = initialState
    }//init
    
    // MARK: - Mutate(실제로 일어날 변화 구현) Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        
        print(#function)
        
        switch action {
            /// 초기 루틴 선택 시
            /// 현재 루틴 선택 후 운동 편집 창에서 시작 시 EditRoutineCoordinator에서 바로 실행됨!
        case .routineSelected:
            // 모든 카드 뷰의 상태를 초기화하고, 첫 운동의 첫 세트를 보여줌
            let updatedCardStates = currentState.workoutRoutine.workouts.enumerated().map { (i, workout) in
                let firstSet = workout.sets.first!
                return WorkoutCardState(
                    currentExerciseName: workout.name,
                    currentWeight: firstSet.weight,
                    currentUnit: firstSet.unit,
                    currentReps: firstSet.reps,
                    setInfo: workout.sets,
                    setIndex: 0,
                    exerciseIndex: i,
                    totalExerciseCount: currentState.workoutRoutine.workouts.count,
                    totalSetCount: workout.sets.count,
                    currentExerciseNumber: i + 1,
                    currentSetNumber: 1,
                    setProgressAmount: 0,
                    memoInExercise: workout.comment,
                    allSetsCompleted: false
                )
            }
            
            // 운동 타이머
            let workoutTimer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.asyncInstance)
                .take(until: self.state.map { !$0.isWorkingout }.filter { $0 }) // 운동 끝나면 중단
                .withLatestFrom(self.state.map{ $0.isWorkoutPaused }) { _, isPaused in return isPaused }
                .filter { !$0 }
                .map { _ in Mutation.workoutTimeUpdating }
                .observe(on: MainScheduler.asyncInstance)
            
            return .concat([
                .just(.setWorkingout(true)),
                workoutTimer,
                .just(.initializeWorkoutCardStates(updatedCardStates))
            ])
            
            // MARK: - 세트 완료 버튼 클릭 시 로직
            /// 세트 완료는 세트 완료 버튼을 누른 카드 기준으로 변경
        case let .setCompleteButtonClicked(cardIndex):
            print("mutate - \(cardIndex)번 인덱스 뷰에서 세트 완료 버튼 클릭!")
            
            return .concat([
                .just(.stopRestTimer(false)),
                .just(.setUpdatingIndex(cardIndex)),
                handleWorkoutFlow(cardIndex, isResting: true, restTime: currentState.restTime)
            ])
            
            // MARK: - skip 버튼 클릭 시 - 휴식 스킵 and (다음 세트 or 다음 운동) 진행
            /// 세트 스킵, 휴식 스킵은 유저한테 보여지는 카드 기준으로 변경
        case let .forwardButtonClicked(cardIndex):
            print("mutate - \(cardIndex)번 인덱스 뷰에서 스킵 버튼 클릭!")
            if currentState.isResting {
                // 휴식 중일 때 휴식만 종료
                return .just(.stopRestTimer(true))
            } else {
                // 그 외엔 휴식 없이 바로 진행
                return .concat([
                    handleWorkoutFlow(cardIndex, isResting: false, restTime: currentState.restTime)
                ])
            }
            
        case .workoutPauseButtonClicked:
            if currentState.isRestPaused {
                // 현재 일시정지 상태 → 재생으로 전환
                // interval을 restSecondsRemaining에서 재시작
                let restTimer = Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
                    .take(Int(currentState.restSecondsRemaining * 10))
                    .take(until: self.state.map {
                        $0.isRestPaused || !$0.isResting || $0.isRestTimerStopped }
                        .filter { $0 }
                    )
                    .map { _ in Mutation.restRemainingSecondsUpdating }
                    .observe(on: MainScheduler.asyncInstance)
                
                return .concat([
                    .just(.pauseAndPlayWorkout(!currentState.isWorkoutPaused)),
                    .just(.pauseRest(!currentState.isRestPaused)),
                    restTimer
                ])
            } else {
                return .concat([
                    .just(.pauseAndPlayWorkout(!currentState.isWorkoutPaused)),
                    .just(.pauseRest(!currentState.isRestPaused))
                ])
            }
            
            // 하단 휴식 버튼 누를 시 동작
        case .setRestTime(let newRestTime):
            print("설정된 휴식시간: \(newRestTime)")
            return .concat([
                .just(.setRestTime(newRestTime))
            ])
            
        case .pageChanged(let newPageIndex):
            // 해당 페이지로 운동 인덱스 변경
            return .just(.changeExerciseIndex(newPageIndex))
            
        case .restPauseButtonClicked:
            if currentState.isRestPaused {
                // 현재 일시정지 상태 → 재생으로 전환
                // interval을 restSecondsRemaining에서 재시작
                let restTimer = Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
                    .take(Int(currentState.restSecondsRemaining * 10))
                    .take(until: self.state.map {
                        $0.isRestPaused || !$0.isResting || $0.isRestTimerStopped }
                        .filter { $0 }
                    )
                    .map { _ in Mutation.restRemainingSecondsUpdating }
                    .observe(on: MainScheduler.asyncInstance)
                
                return .concat([
                    .just(.pauseRest(false)),
                    restTimer
                ])
            } else {
                // 재생 상태 → 일시정지로 전환
                // interval 종료, 남은 시간만 보존
                return .just(.pauseRest(true))
            }
            
        case .stopButtonClicked(let isEnded):
            return .concat([
                .just(.stopRestTimer(true)),
                .just(.setWorkingout(false)),
                .just(.setResting(false)),
                .just(.setRestTime(0)),
                .just(.saveWorkoutData),
                .just(.manageWorkoutData(isEnded: true))
            ])
            
        case let .editAndMemoViewPresented(cardIndex):
            let currentExerciseIndex = currentState.currentExerciseIndex
            let currentExercise = currentState.workoutCardStates[currentExerciseIndex]
            let currentExerciseMemo = currentExercise.memoInExercise
            print("📋 현재메모: \(String(describing: currentExerciseMemo))")
            
            return .just(.setEditAndMemoViewPresented(true))
            
        case .updateCurrentExerciseMemo(let newMemo):
            return .concat([
                .just(.updateExerciseMemo(with: newMemo)),
                .just(.saveWorkoutData)
            ])
            
        case let .editExerciseViewPresented(cardIndex, isPresented):
            return .concat([
                .just(.convertToEditData(at: cardIndex)),
                .just(.setEditExerciseViewPresented(isPresented))
            ])
            
        case let .confirmButtonClickedForSaving(newMemo):
            if newMemo != nil,
               newMemo != currentState.memoInRoutine {
                return .just(.saveWorkoutData)
            } else {
                return .empty()
            }
            
        case let .updateCurrentRoutineMemo(with: newMemo):
            return .concat([
                .just(.updateRoutineMemo(with: newMemo)),
                .just(.saveWorkoutData)
            ])
            
        // 삭제될 시에만 활용
        case let .cardDeleteAnimationCompleted(oldIndex: oldIndex, nextIndex: nextIndex):
            let oldCardState = currentState.workoutCardStates[oldIndex]
            return .concat([
                .just(.manageDataIfForwarded(
                    isRoutineCompleted: false,
                    isCurrentExerciseCompleted: true
                )),
                .just(.updateWorkoutCardState(
                    updatedCardState: currentState.workoutCardStates[nextIndex],
                    oldCardState: oldCardState,
                    oldCardIndex: oldIndex)),
                .just(.changeExerciseIndex(nextIndex)),
                .just(.setUpdatingIndex(nextIndex))
            ])
        }//action
    }//mutate
    
    
    // MARK: - Reduce(state를 바꿀 수 있는 유일한 곳, 새로운 state를 리턴) Mutaion -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
            
        case let .setWorkingout(isWorkingout):
            newState.isWorkingout = isWorkingout
            
        case let .setWorkoutTime(time):
            newState.workoutTime = time
            
        case let .pauseAndPlayWorkout(isPaused):
            newState.isWorkoutPaused = isPaused
            
        case let .setResting(isResting):
            newState.isResting = isResting
            if !newState.isResting {
                newState.restSecondsRemaining = 0.0
                newState.restStartTime = nil
            }
            print("휴식중? \(newState.isResting)")
            
            // 휴식 버튼으로 휴식 시간 설정 시
        case let .setRestTime(restTime):
            // 초기화 버튼 클릭 시 0으로 설정
            if restTime == 0 {
                newState.restTime = restTime
            } else {
                newState.restTime += restTime
            }
            
        case let .setRestTimeDataAtProgressBar(restTime):
            if restTime > 0 {
                newState.restStartTime = restTime
                newState.restSecondsRemaining = restTime
                newState.isRestTimerStopped = false
            } else {
                newState.restStartTime = nil
                newState.restSecondsRemaining = 0.0
                newState.isRestTimerStopped = true
            }
            
        case let .manageDataIfForwarded(isRoutineCompleted, isCurrentExerciseCompleted):
            
            if isRoutineCompleted,
               isCurrentExerciseCompleted { // 루틴 전체 완료
                newState.isWorkingout = false
                print("루틴 전체 완료 - \(!newState.isWorkingout)")
                // MARK: - TODO: 운동 완료 후 기록 저장 등의 추가 작업
            } else if isCurrentExerciseCompleted { // 현재 운동만 완료
                // 현재 세트 완료 false로 재설정
                newState.didExerciseCount += 1
                print("현재 운동 완료")
            } else { // 다음 세트로
                newState.didSetCount += 1
                print("다음 세트로 - \(newState.workoutCardStates[newState.currentExerciseIndex].setIndex)")
            }
            print("🚬 완료한 세트 수: \(newState.didSetCount), 완료한 운동 수: \(newState.didExerciseCount)")
            
        case let .updateWorkoutCardState(updatedState, oldState, oldIndex):
            
            // 기존 카드 마지막 프로그레스바 하나 채우고, 모든 세트 완료 처리
            if var oldState, let oldIndex {
                oldState.setProgressAmount += 1
                oldState.allSetsCompleted = true
                newState.workoutCardStates[oldIndex] = oldState
                // 기존 카드 상태 업데이트
                print("ℹ️ 이전 카드 State: \(oldState.currentExerciseName)")
            }
            
            print("ℹ️ UpdatingIndex: \(newState.updatingIndex)")
            // 새로운 카드 상태 업데이트
            newState.workoutCardStates[newState.updatingIndex] = updatedState
            
            // 새로운 카드 모든 세트 완료 다시 false로 설정
            newState.currentExerciseAllSetsCompleted = false
            print("ℹ️ 업데이트된 카드 State: \(updatedState.currentExerciseName), \(updatedState.currentSetNumber)세트 째, \(updatedState.currentExerciseNumber)번째 운동 (모든세트완료?: \(updatedState.allSetsCompleted ? "TRUE" : "FALSE"))")
            
        case let .initializeWorkoutCardStates(cardStates):
            newState.workoutCardStates = cardStates
            newState.currentExerciseIndex = 0 // 첫 운동으로 초기화
            
        case .workoutTimeUpdating:
            newState.workoutTime += 1
            
        case .restRemainingSecondsUpdating:
            if newState.isResting,
               !newState.isWorkoutPaused,
               !newState.isRestPaused,
               !newState.isRestTimerStopped {
                // 0.1초씩 감소
                newState.restSecondsRemaining = max(newState.restSecondsRemaining - 0.1, 0)
                //                print("REACTOR - 남은 휴식 시간: \(newState.restSecondsRemaining)")
                if newState.restSecondsRemaining.rounded() == 0.0 {
                    newState.isResting = false
                    newState.isRestTimerStopped = true
                    
                    // 휴식 종료 시 푸시 알림
                    NotificationService.shared.sendRestFinishedNotification()
                }
            }
            
        case let .pauseRest(isPaused):
            newState.isRestPaused = isPaused
            
        // MARK: - 운동 종료 시 운동 관련 데이터 핸들
        // 추후에 종료가 아닐 시에도 저장할 일이 있을 것 같아 isEnded 그대로 두었음
        case let .manageWorkoutData(isEnded):
            newState.didExerciseCount += 1
            print("🎬 [manageWorkoutData] 완료한 세트 수: \(newState.didSetCount), 완료한 운동 수: \(newState.didExerciseCount)")
            
            // 저장될 데이터들
            newState.workoutRecord = WorkoutRecord(
                // TODO: 검토 필요
                id: UUID().uuidString,
                workoutRoutine: newState.workoutRoutine,
                totalTime: newState.workoutTime,
                workoutTime: newState.workoutTime,
                comment: newState.memoInRoutine,
                date: newState.date
            )
            
            let routineDidProgress = Float(newState.didSetCount) / Float(newState.totalSetCountInRoutine)
            
            // 운동 완료 화면에 보여질 데이터들
            newState.workoutSummary = WorkoutSummary(
                routineName: newState.workoutRoutine.name,
                date: newState.date,
                routineDidProgress: routineDidProgress,
                totalTime: newState.workoutTime,
                exerciseDidCount: newState.didExerciseCount,
                setDidCount: newState.didSetCount,
                routineMemo: newState.memoInRoutine
            )
            print("🎬 [WorkoutSummary]: \(newState.workoutSummary)")
            
            // TODO: - saveUsecase 실행
            
        case let .setTrueCurrentCardViewCompleted(cardIndex):
            if newState.workoutCardStates.indices.contains(cardIndex) {
                newState.currentExerciseAllSetsCompleted = true
                newState.didSetCount += 1
                
                newState.workoutCardStates.forEach {
                    print("\($0.currentExerciseName), \( $0.allSetsCompleted)")
                }
            }
            
        case let .changeExerciseIndex(newIndex):
            print("🔍 현재 운동 인덱스!: \(newIndex)")
            newState.currentExerciseIndex = newIndex
            newState.updatingIndex = newIndex
            
        case let .setEditAndMemoViewPresented(presented):
            newState.isEditAndMemoViewPresented = presented
            
        case let .updateExerciseMemo(newMemo):
            let currentExerciseIndex = currentState.currentExerciseIndex
            newState.workoutCardStates[currentExerciseIndex].memoInExercise = newMemo
            print("📋 변경된메모: \(String(describing: newMemo)), \(String(describing: newState.workoutCardStates[currentExerciseIndex].memoInExercise))")
            
            let currentWorkout = Workout(
                id: newState.uid ?? "",
                name: newState.workoutCardStates[currentExerciseIndex].currentExerciseName,
                sets: newState.workoutCardStates[currentExerciseIndex].setInfo,
                comment: newState.workoutCardStates[currentExerciseIndex].memoInExercise
            )
            
            updateWorkoutUseCase.execute(item: currentWorkout)
                        
        case let .stopRestTimer(isStopped):
            if isStopped {
                newState.isResting = false
                newState.isRestTimerStopped = true
                newState.restSecondsRemaining = 0.0
                newState.restStartTime = nil
            } else {
                newState.isResting = true
                newState.isRestTimerStopped = false
                newState.restSecondsRemaining = Float(newState.restTime)
                newState.restStartTime = nil
            }
            
        // MARK: - 현재 운동 데이터 저장
        // 메모 창 dismiss시, 운동 완료 시 등등
        case .saveWorkoutData:
            let updatedWorkouts = convertWorkoutCardStatesToWorkouts(
                cardStates: newState.workoutCardStates)
            
            newState.workoutRoutine = WorkoutRoutine(
                id: newState.uid ?? "",
                name: newState.workoutRoutine.name,
                workouts: updatedWorkouts
            )
            newState.workoutRecord = WorkoutRecord(
                id: newState.uid ?? "",
                workoutRoutine: newState.workoutRoutine,
                totalTime: newState.workoutTime,
                workoutTime: newState.workoutTime,
                comment: newState.memoInRoutine,
                date: Date()
            )
//            
//            saveRecordUseCase.execute(item: newState.workoutRecord)
//            if let uid = newState.uid {
//                fsSaveRecordUseCase.execute(uid: uid, item: newState.workoutRecord)
//            } else {
//                print("사용자 uid가 없습니다!")
//            }
            
        case let .convertToEditData(cardIndex):
            let currentExercise = newState.workoutCardStates[cardIndex]
            let currentSetsData = newState.workoutRoutine.workouts[cardIndex].sets.map { set in
                [String(set.weight), String(set.reps)]
            }
            newState.workoutStateForEdit = WorkoutStateForEdit(
                currentRoutine: newState.workoutRoutine,
                currentExcerciseName: currentExercise.currentExerciseName,
                currentUnit: currentExercise.currentUnitForSave,
                currentWeightSet: currentSetsData
            )
            
        case let .updateRoutineMemo(with: newMemo):
            newState.memoInRoutine = newMemo
            
        case let .setEditExerciseViewPresented(isPresented):
            print("isEditExerciseViewPresented: \(isPresented)")
            newState.isEditExerciseViewPresented = isPresented
            
        case let .setUpdatingIndex(cardIndex):
            print("Updating인 CARDINDEX: \(cardIndex)")
            newState.updatingIndex = cardIndex
            
        case let .setWorkoutStartDate(date):
            newState.workoutStartDate = date
            
        case let .setAccumulatedWorkoutTime(time):
            newState.accumulatedWorkoutTime = time
            
        }//switch mutation
        return newState
    }//reduce
}

// MARK: - Private Methods
private extension HomeViewReactor {
    
    /// 스킵(다음) 버튼 클릭 시 mutate내에서 실행되는 전반적인 기능 로직
    func handleWorkoutFlow(
        _ cardIndex: Int,
        isResting: Bool,
        restTime: Float
    ) -> Observable<HomeViewReactor.Mutation> {
        
        print("현재 보여지는 카드의 인덱스(서로 동일해야 함): \(currentState.currentExerciseIndex)")
        
        let nextSetIndex = currentState.workoutCardStates[cardIndex].setIndex + 1
        let currentWorkout = currentState.workoutRoutine.workouts[cardIndex]
        var currentCardState = currentState.workoutCardStates[cardIndex]
        
        // 휴식 타이머
        var restTimer: Observable<HomeViewReactor.Mutation> = .empty()
        
        if isResting {
            let restTime = currentState.restTime
            let tickCount = restTime * 10 // 0.1초 간격으로 진행
            // 휴식 타이머
            restTimer = Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
                .take(Int(tickCount))
                .take(until: self.state.map {
                    $0.isRestPaused || !$0.isResting || $0.isRestTimerStopped }
                    .filter { $0 }
                )
                .map { _ in Mutation.restRemainingSecondsUpdating }
                .observe(on: MainScheduler.asyncInstance)
        }
        
        // 다음 세트가 있는 경우 (휴식 시작)
        // 해당 상태에서 Forward 버튼을 누르면 휴식 스킵
        if nextSetIndex < currentCardState.totalSetCount {
                        
            let nextSet = currentWorkout.sets[nextSetIndex]
            
            currentCardState.setIndex = nextSetIndex
            currentCardState.currentSetNumber = nextSetIndex + 1
            currentCardState.setProgressAmount += 1
            currentCardState.currentWeight = nextSet.weight
            currentCardState.currentUnit = nextSet.unit
            currentCardState.currentReps = nextSet.reps
            
            /// 변경된 카드 State!
            let updatedCardState = currentCardState
            
            print("현재 세트 정보: \(updatedCardState)")
            print("설정될 휴식시간: \(restTime)초")
            
            return .concat([
                .just(.setResting(isResting)),
                // 카드 정보 업데이트
                .just(.updateWorkoutCardState(updatedCardState: updatedCardState)),
                .just(.manageDataIfForwarded(
                    isRoutineCompleted: false,
                    isCurrentExerciseCompleted: false
                )),
                .just(.setRestTimeDataAtProgressBar(restTime)),
                restTimer
            ])
            .observe(on: MainScheduler.instance)
        } else { // 현재 운동의 모든 세트 완료(카드 삭제), 다음 운동으로 이동 또는 루틴 종료
            var nextExerciseIndex = currentState.workoutCardStates.indices.contains(cardIndex) ? cardIndex : 0
            let currentCardState = currentState.workoutCardStates[cardIndex]
            print("🗂️🗂️ 초기 nextExerciseIndex: \(nextExerciseIndex)")
            
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
            
            if nextExerciseIndex != cardIndex {
            
                return .concat([
                    .just(.setResting(isResting)),
                    .just(.setTrueCurrentCardViewCompleted(at: cardIndex)),
                    .just(.setRestTimeDataAtProgressBar(restTime)),
                    restTimer
                ])
                .observe(on: MainScheduler.instance)
            } else { // nextExerciseIndex == cardIndex일때
                
                let allCompleted = currentState.workoutCardStates
                    .allSatisfy { $0.allSetsCompleted }
                
                if allCompleted { // 모든 운동 루틴 완료 시
                    print("--- 모든 운동 루틴 완료! ---")
                    return .concat([
                        .just(.stopRestTimer(true)),
                        .just(.setWorkingout(false)),
                        .just(.setResting(false)),
                        .just(.setRestTime(0)),
                        .just(.manageWorkoutData(isEnded: true))
                    ])
                    .observe(on: MainScheduler.instance)
                } else { // 운동 끝나지 않은 카드 1개 남았을 떄
                    print("남은 카드 1개")
                    return .concat([
                        .just(.setResting(isResting)),
                        .just(.setTrueCurrentCardViewCompleted(at: cardIndex)),
                        .just(.setRestTimeDataAtProgressBar(restTime)),
                        restTimer
                    ])
                    .observe(on: MainScheduler.instance)
                }
            }
        }
    }
    
    /// [WorkoutCardState] -> [Workout] 로 변환
    func convertWorkoutCardStatesToWorkouts(cardStates: [WorkoutCardState]) -> [Workout] {
        return cardStates.map { card in
            Workout(
                id: UUID().uuidString,
                name: card.currentExerciseName,
                sets: card.setInfo,
                comment: card.memoInExercise
            )
        }
    }
}

// MARK: - LiveActivity State
extension HomeViewReactor.State {
    var forLiveActivity: WorkoutDataForLiveActivity {
        guard workoutCardStates.indices.contains(currentExerciseIndex) else {
            // 기본 데이터
            return WorkoutDataForLiveActivity(
                workoutTime: 0,
                isWorkingout: false,
                exerciseName: "",
                exerciseInfo: "",
                isResting: false,
                restSecondsRemaining: 0,
                isRestPaused: false,
                currentSet: 0,
                totalSet: 0,
                currentIndex: 0
            )
        }
        
        let exercise = workoutCardStates[currentExerciseIndex]
        let reps = exercise.currentRepsForSave
        let weight: String
        if exercise.currentWeightForSave.truncatingRemainder(dividingBy: 1) == 0 {
            weight = String(Int(exercise.currentWeightForSave))
        } else {
            weight = String(exercise.currentWeightForSave)
        }
        let unit = exercise.currentUnitForSave
        let repsText = "회"
        let exerciseInfo = "\(weight)\(unit) X \(reps)\(repsText)"

        return WorkoutDataForLiveActivity(
            workoutTime: workoutTime,
            isWorkingout: isWorkingout,
            exerciseName: exercise.currentExerciseName,
            exerciseInfo: exerciseInfo,
            isResting: isResting,
            restSecondsRemaining: restSecondsRemaining,
            isRestPaused: isRestPaused,
            currentSet: exercise.setProgressAmount,
            totalSet: exercise.totalSetCount,
            currentIndex: currentExerciseIndex
        )
    }
}

// MARK: - 운동 진행 상태 UserDefaults
// TODO: - 추후에 살릴 수도 있음
// 앱 스위처에서 스와이프 종료 후에도 운동 상태 남기기 위함

///// UserDefaults로 운동상태 Save
//func saveCurrentWorkoutState(_ state: HomeViewReactor.State) {
//    if let encoded = try? JSONEncoder().encode(state) {
//        UserDefaults.standard.set(encoded, forKey: "currentWorkoutState")
//    }
//}
//
///// UserDefaults에서 운동상태 Load
//func loadCurrentWorkoutState() -> HomeViewReactor.State? {
//    if let data = UserDefaults.standard.data(forKey: "currentWorkoutState"),
//       let state = try? JSONDecoder().decode(HomeViewReactor.State.self, from: data) {
//        return state
//    }
//    return nil
//}

// MARK: InitialState 관련
extension HomeViewReactor {
    
    /// 운동 편집 뷰에서 받아온 WorkoutRoutine을 가지고 있는 InitialState
    /// 바로 시작 되도록 isWorkingout = true
    static func fetchedInitialState(routine: WorkoutRoutine) -> State {
        // MARK: - TODO: MOCKDATA -> 실제 데이터로 수정
        // 루틴 선택 시 초기 값 설정
        let initialRoutine = routine
        // 초기 운동 카드 뷰들 state 초기화
        var initialWorkoutCardStates: [WorkoutCardState] = []
        /// 루틴 전체의 세트 수
        var initialTotalSetCountInRoutine = 0
        // 현재 루틴의 모든 정보를 workoutCardStates에 저장
        for (i, workout) in initialRoutine.workouts.enumerated() {
            initialWorkoutCardStates.append(WorkoutCardState(
                currentExerciseName: workout.name,
                currentWeight: workout.sets[0].weight,
                currentUnit: workout.sets[0].unit,
                currentReps: workout.sets[0].reps,
                setInfo: workout.sets,
                setIndex: 0,
                exerciseIndex: i,
                totalExerciseCount: initialRoutine.workouts.count,
                totalSetCount: workout.sets.count,
                currentExerciseNumber: i + 1,
                currentSetNumber: 1,
                setProgressAmount: 0,
                memoInExercise: workout.comment,
                allSetsCompleted: false
            ))
            initialTotalSetCountInRoutine += workout.sets.count
        }
        
        let initialWorkoutRecord = WorkoutRecord(
            // TODO: 검토 필요
            id:  UUID().uuidString,
            workoutRoutine: initialRoutine,
            totalTime: 0,
            workoutTime: 0,
            comment: "",
            date: Date()
        )
        
        let initialWorkoutSummary = WorkoutSummary(
            routineName: initialRoutine.name,
            date: Date(),
            routineDidProgress: 0.0,
            totalTime: 0,
            exerciseDidCount: 0,
            setDidCount: 0,
            routineMemo: initialWorkoutRecord.comment
        )
        
        let firstWorkout = initialRoutine.workouts[0]
        let weightSet: [[String]] = firstWorkout.sets.map { set in
            [String(set.weight), String(set.reps)]
        }
        let initialWorkoutStateForEdit = WorkoutStateForEdit(
            currentRoutine: initialRoutine,
            currentExcerciseName: firstWorkout.name,
            currentUnit: firstWorkout.sets.first?.unit ?? "kg",
            currentWeightSet: weightSet
        )
        
        return State(
            workoutRoutine: initialRoutine,
            workoutCardStates: initialWorkoutCardStates,
            currentExerciseIndex: 0,
            updatingIndex: 0,
            isWorkingout: false,
            isWorkoutPaused: false,
            workoutTime: 0,
            isResting: false,
            isRestPaused: false,
            restSecondsRemaining: 60.0,
            restTime: 60.0, // 기본 60초로 설정
            restStartTime: nil,
            date: Date(),
            memoInRoutine: initialWorkoutRecord.comment,
            currentExerciseAllSetsCompleted: false,
            isEditAndMemoViewPresented: false,
            isEditExerciseViewPresented: false,
            isRestTimerStopped: false,
            workoutRecord: initialWorkoutRecord,
            workoutSummary: initialWorkoutSummary,
            totalExerciseCount: initialWorkoutCardStates.count,
            didExerciseCount: 0,
            totalSetCountInRoutine: initialTotalSetCountInRoutine,
            didSetCount: 0,
            uid: FirebaseAuthService().fetchCurrentUser()?.uid,
            workoutStateForEdit: initialWorkoutStateForEdit,
            accumulatedWorkoutTime: 0
        )
    }
}
