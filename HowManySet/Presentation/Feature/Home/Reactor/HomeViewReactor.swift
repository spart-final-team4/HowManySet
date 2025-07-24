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
        case stopButtonClicked
        /// 카드의 운동 옵션 버튼 클릭으로 editAndMemoView present시
        case editAndMemoViewPresented(at: Int)
        /// MemoTextView의 메모로 업데이트
        case updateCurrentExerciseMemoWhenDismissed(with: String)
        /// 운동 편집 모달에서 저장하기 클릭 시
        case saveButtonClickedAtEditExercise
        /// 운동 완료 화면에서 확인 클릭 시 - 루틴 메모만 Update
        case confirmButtonClickedForSavingMemo(newMemo: String?)
        /// 운동 완료 후 카드 삭제 완료
        case cardDeleteAnimationCompleted(oldIndex: Int, nextIndex: Int)
        /// background -> foreground로 올때 운동 시간 조정
        case adjustWorkoutTimeOnForeground
        /// background -> foreground로 올때 남은 휴식 시간 조정
        case adjustRestRemainingTimeOnForeground
        /// background로 진입 시 휴식 restStartDate 설정 위함
        case didEnterBackgroundWhileResting
        case routineCompleted
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setWorkingout(Bool)
        case setWorkoutTime(Int)
        case setResting(Bool)
        /// 하단 휴식 버튼 누를 시 동작
        case setRestTime(Float)
        /// 휴식 프로그레스 휴식 시간 설정
        case setRestTimeDataAtProgressBar(Float, Float? = nil)
        case workoutTimeUpdating
        case restRemainingUpdating
        case pauseAndPlayWorkout(Bool)
        case pauseRest(Bool)
        /// 운동 완료 시 usecase이용해서 데이터 저장
        case saveWorkoutData
        /// 스킵(다음) 버튼 클릭 시 세트/운동 카운팅
        case manageWorkoutCount(isCurrentExerciseCompleted: Bool)
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
        case updateRoutineMemo(with: String?)
        /// updatingIndex 설정
        case setUpdatingIndex(Int)
        // 백그라운드 관련
        case setWorkoutStartDate(Date?) /// 운동 시작 시각 설정
        case setWorkoutTimeWhenBackgrounded(TimeInterval) /// 총 누적된 운동 시간 (+background) 설정
        case setRestRemainingStartDate(Date?) /// 남은 휴식 시작 시각 설정
        case setRestRemainingTimeWhenBackgrounded(TimeInterval) /// 총 누적된 남은 휴식 시간 (+background) 설정
        /// 현재 루틴 완료 설정
        case setCurrentRoutineCompleted
        /// 운동 편집 시 최신 Routine 로드
        case loadUpdatedRoutine([WorkoutRoutine])
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
        var restRemainingTime: Float
        /// 기본 휴식 시간
        var restTime: Float
        /// 휴식이 시작될 때의 값 (프로그레스바 용)
        var restStartTime: Float?
        var date: Date
        var memoInRoutine: String?
        var currentExerciseAllSetsCompleted: Bool
        var isEditAndMemoViewPresented: Bool
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
        var currentWorkoutData: Workout
        // 백그라운드 용
        var workoutStartDate: Date? /// 운동 시작 시각
        var accumulatedWorkoutTime: TimeInterval /// 총 누적된 운동 시간 (+background)
        var restStartDate: Date? /// 휴식 시작 시각
        var accumulatedRestRemainingTime: TimeInterval /// 총 누적된 휴식 시간 (+background)
        /// 현재 루틴의 모든 운동 완료
        var currentRoutineCompleted: Bool
        /// 현재 사용자 uid
        var uid: String?
        /// 현재 루틴 ID
        var documentID: String
        /// 현재  WorkoutRecordID
        var recordID: String
    }
    
    // initialState 주입으로 변경
    let initialState: State
    
    private let saveRecordUseCase: SaveRecordUseCase
    private let fetchRoutineUseCase: FetchRoutineUseCase
    /// 메모 dismiss, 운동 종료/완료 시 WorkoutUpdate (+ 각 운동에 대한 메모)
    private let updateWorkoutUseCase: UpdateWorkoutUseCase
    
    private let uid = FirebaseAuthService().fetchCurrentUser()?.uid
    
    /// 운동 종료/완료시 RecordUpdate (+ 루틴에 대한 메모)
    private let updateRecordUseCase: UpdateRecordUseCase
    
    init(
        saveRecordUseCase: SaveRecordUseCase,
        fetchRoutineUseCase: FetchRoutineUseCase,
        updateWorkoutUseCase: UpdateWorkoutUseCase,
        updateRecordUseCase: UpdateRecordUseCase,
        initialState: State
    ) {
        self.saveRecordUseCase = saveRecordUseCase
        self.fetchRoutineUseCase = fetchRoutineUseCase
        self.updateWorkoutUseCase = updateWorkoutUseCase
        self.updateRecordUseCase = updateRecordUseCase
        self.initialState = initialState
    }//init
    
    // MARK: - Mutate(실제로 일어날 변화 구현) Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            /// 초기 루틴 선택 시
            /// 현재 루틴 선택 후 운동 편집 창에서 시작 시 EditRoutineCoordinator에서 바로 실행됨!
        case .routineSelected:
            // 운동 타이머
            let workoutTimer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.asyncInstance)
                .take(until: self.state.map { !$0.isWorkingout }.filter { $0 }) // 운동 끝나면 중단
                .withLatestFrom(self.state.map { $0.isWorkoutPaused }) { _, isPaused in return isPaused }
                .filter { !$0 }
                .map { _ in Mutation.workoutTimeUpdating }
                .observe(on: MainScheduler.asyncInstance)
            
            return .concat([
                .just(.setWorkingout(true)),
                .just(.setWorkoutStartDate(Date())),
                workoutTimer
            ])
            
            // MARK: - 세트 완료 버튼 클릭 시 로직
            /// 세트 완료는 세트 완료 버튼을 누른 카드 기준으로 변경
        case let .setCompleteButtonClicked(cardIndex):
            if currentState.isResting {
                return .empty()
            } else {
                return .concat([
                    .just(.pauseRest(false)),
                    .just(.stopRestTimer(false)),
                    .just(.setUpdatingIndex(cardIndex)),
                    handleWorkoutFlow(cardIndex, isResting: true, restTime: currentState.restTime)
                ])
            }
            
            // MARK: - skip 버튼 클릭 시 - 휴식 스킵 and (다음 세트 or 다음 운동) 진행
            /// 세트 스킵, 휴식 스킵은 유저한테 보여지는 카드 기준으로 변경
        case let .forwardButtonClicked(cardIndex):
            if currentState.isResting {
                // 휴식 중일 때 휴식만 종료
                return .concat([
                    .just(.pauseRest(false)),
                    .just(.stopRestTimer(true))
                ])
            } else {
                // 그 외엔 휴식 없이 바로 진행
                return .concat([
                    .just(.pauseRest(false)),
                    handleWorkoutFlow(cardIndex, isResting: false, restTime: currentState.restTime)
                ])
            }
            
        case .workoutPauseButtonClicked:
            if currentState.isRestPaused {
                // 현재 일시정지 상태 → 재생으로 전환
                // interval을 restSecondsRemaining에서 재시작
                let restTimer = Observable<Int>.interval(.milliseconds(10), scheduler: MainScheduler.asyncInstance)
                    .take(Int(currentState.restRemainingTime * 100))
                    .take(until: self.state.map {
                        $0.isRestPaused || !$0.isResting || $0.isRestTimerStopped }
                        .filter { $0 }
                    )
                    .map { _ in Mutation.restRemainingUpdating }
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
            return .just(.setRestTime(newRestTime))
            
        case .pageChanged(let newPageIndex):
            // 해당 페이지로 운동 인덱스 변경
            return .just(.changeExerciseIndex(newPageIndex))
            
        case .restPauseButtonClicked:
            if currentState.isRestPaused {
                // 현재 일시정지 상태 → 재생으로 전환
                // interval을 restSecondsRemaining에서 재시작
                let restTimer = Observable<Int>.interval(.milliseconds(10), scheduler: MainScheduler.asyncInstance)
                    .take(Int(currentState.restRemainingTime * 100))
                    .take(until: self.state.map {
                        $0.isRestPaused || !$0.isResting || $0.isRestTimerStopped }
                        .filter { $0 }
                    )
                    .map { _ in Mutation.restRemainingUpdating }
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
            
        case .stopButtonClicked:
            return .concat([
                .just(.stopRestTimer(true)),
                .just(.setWorkingout(false)),
                .just(.setResting(false)),
                .just(.setRestTime(0)),
                .just(.saveWorkoutData)
            ])
            
        case let .editAndMemoViewPresented(cardIndex):
            let currentExercise = currentState.workoutCardStates[cardIndex]
            return .just(.setEditAndMemoViewPresented(true))
            
        case .updateCurrentExerciseMemoWhenDismissed(let newMemo):
            return .just(.updateExerciseMemo(with: newMemo))
            
        case .saveButtonClickedAtEditExercise:
            return fetchRoutineUseCase.execute(uid: currentState.uid)
                .map { Mutation.loadUpdatedRoutine($0) }.asObservable()
            
        case let .confirmButtonClickedForSavingMemo(newMemo):
            if newMemo != nil,
               newMemo != currentState.memoInRoutine {
                return .just(.updateRoutineMemo(with: newMemo))
            } else {
                return .empty()
            }
            
            // 삭제될 시에만 활용
        case let .cardDeleteAnimationCompleted(oldIndex: oldIndex, nextIndex: nextIndex):
            var oldCardState = currentState.workoutCardStates[oldIndex]
            oldCardState.setProgressAmount += 1
            
            if oldIndex != nextIndex {
                return .concat([
                    .just(.manageWorkoutCount(isCurrentExerciseCompleted: true)),
                    .just(.updateWorkoutCardState(
                        updatedCardState: currentState.workoutCardStates[nextIndex],
                        oldCardState: oldCardState,
                        oldCardIndex: oldIndex)),
                    .just(.changeExerciseIndex(nextIndex)),
                    .just(.setUpdatingIndex(nextIndex))
                ])
            } else {
                return .concat([
                    .just(.manageWorkoutCount(isCurrentExerciseCompleted: true)),
                    .just(.setCurrentRoutineCompleted),
                    .just(.setResting(false)),
                    .just(.setRestTime(0)),
                    .just(.stopRestTimer(true)),
                    .just(.setWorkingout(false))
                ])
            }
            
            // 백그라운드 시간도 포함한 운동 시간 설정
        case .adjustWorkoutTimeOnForeground:
            if let startDate = currentState.workoutStartDate {
                let elapsedTime = Date().timeIntervalSince(startDate)
                return .concat([
                    .just(.setWorkoutTimeWhenBackgrounded(currentState.accumulatedWorkoutTime + elapsedTime)),
                    .just(.setWorkoutStartDate(Date())) // 다시 시작 시각 기록 (초기화)
                ])
            } else {
                return .empty()
            }
            
        case .routineCompleted:
            return .just(.setCurrentRoutineCompleted)
            
            // 백그라운드 시간도 포함한 휴식 시간 설정
        case .adjustRestRemainingTimeOnForeground:
            if let startDate = currentState.restStartDate {
                let elapsedTime = Date().timeIntervalSince(startDate)
                let newRestRemainingTime = max(0, currentState.accumulatedRestRemainingTime - elapsedTime)
                return .just(.setRestTimeDataAtProgressBar(currentState.restTime, Float(newRestRemainingTime)))
            } else {
                return .empty()
            }
            
        case .didEnterBackgroundWhileResting:
            return .concat([
                .just(.setRestRemainingStartDate(Date())),
                // 휴식 중 백그라운드 진입 시 restRemainingTime 설정
                .just(.setRestRemainingTimeWhenBackgrounded(Double(currentState.restRemainingTime)))
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
                newState.restRemainingTime = 0.0
                newState.restStartTime = nil
            }
            
            // 휴식 버튼으로 휴식 시간 설정 시
        case let .setRestTime(restTime):
            // 초기화 버튼 클릭 시 0으로 설정
            if restTime == 0 {
                newState.restTime = restTime
            } else {
                newState.restTime += restTime
            }
            
        case let .setRestTimeDataAtProgressBar(restTime, restRemaining):
            if restTime > 0 {
                newState.restStartTime = restTime
                if let restRemaining {
                    newState.restRemainingTime = restRemaining
                } else {
                    newState.restRemainingTime = restTime
                }
                newState.isRestTimerStopped = false
            } else {
                newState.restStartTime = nil
                newState.restRemainingTime = 0.0
                newState.isRestTimerStopped = true
                newState.isResting = false
            }
            
        case let .manageWorkoutCount(isCurrentExerciseCompleted):
            if isCurrentExerciseCompleted { // 현재 운동 완료
                newState.didExerciseCount += 1
                newState.didSetCount += 1
            } else { // 다음 세트로
                if newState.workoutCardStates[newState.currentExerciseIndex].setIndex <= 1 {
                    newState.didExerciseCount += 1
                }
                newState.didSetCount += 1
            }
            
        case let .updateWorkoutCardState(updatedState, oldState, oldIndex):
            
            // 기존 카드 마지막 프로그레스바 하나 채우고, 모든 세트 완료 처리
            if var oldState, let oldIndex {
                oldState.setProgressAmount += 1
                oldState.allSetsCompleted = true
                newState.workoutCardStates[oldIndex] = oldState
            }
            
            // 새로운 카드 상태 업데이트
            newState.workoutCardStates[newState.updatingIndex] = updatedState
            // 새로운 카드 모든 세트 완료 다시 false로 설정
            newState.currentExerciseAllSetsCompleted = false
            
        case let .initializeWorkoutCardStates(cardStates):
            newState.workoutCardStates = cardStates
            newState.currentExerciseIndex = 0 // 첫 운동으로 초기화
            
        case .workoutTimeUpdating:
            newState.workoutTime += 1
            
        case .restRemainingUpdating:
            if newState.isResting,
               !newState.isWorkoutPaused,
               !newState.isRestPaused,
               !newState.isRestTimerStopped {
                // 0.01초씩 감소
                newState.restRemainingTime = max(newState.restRemainingTime - 0.01, 0)

                if newState.restRemainingTime.rounded() == 0.0 {
                    newState.isResting = false
                    newState.isRestTimerStopped = true
                }
            }
            
        case let .pauseRest(isPaused):
            if isPaused {
                newState.restStartDate = nil
                newState.isRestPaused = true
                NotificationService.shared.removeRestNotification()
            } else {
                if currentState.isResting, currentState.restRemainingTime > 0 {
                    NotificationService.shared.scheduleRestFinishedNotification(seconds: TimeInterval(currentState.restRemainingTime))
                }
                // 현재 시각부터 타이머 재시작
                newState.restStartDate = Date()
                newState.isRestPaused = false
            }
            
            // MARK: - 현재 운동 데이터 저장
            // 운동 완료 시 모든 정보(Record, Summary) 저장
        case .saveWorkoutData:
            let routineDidProgress = Float(newState.didSetCount) / Float(newState.totalSetCountInRoutine)
            let recordID = UUID().uuidString
            newState.recordID = recordID
            
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
            
            /// 사용자가 수행한 운동 배열
            var didWorkout: [Workout] = []
            for (i, workout) in newState.workoutRoutine.workouts.enumerated() {
                let setsDid = Array(workout.sets.prefix(newState.workoutCardStates[i].setProgressAmount))
                if !setsDid.isEmpty {
                    didWorkout.append(Workout(
                        id: workout.id,
                        name: workout.name,
                        sets: setsDid,
                        comment: workout.comment
                    ))
                    print(didWorkout)
                }
            }
            
            let newWorkoutRoutine = WorkoutRoutine(
                rmID: newState.workoutRoutine.rmID,
                documentID: uid ?? "",
                name: newState.workoutRoutine.name,
                workouts: didWorkout // 완료한 운동들
            )
            
            // 저장되는 WorkoutRecord
            let updatedWorkoutRecord = WorkoutRecord(
                rmID: recordID,
                documentID: uid ?? "",
                uuid: recordID,
                workoutRoutine: newWorkoutRoutine,
                totalTime: newState.workoutTime,
                workoutTime: newState.workoutTime,
                comment: newState.memoInRoutine,
                date: Date()
            )
            
            saveRecordUseCase.execute(uid: uid, item: updatedWorkoutRecord)
            
        case let .setTrueCurrentCardViewCompleted(cardIndex):
            if newState.workoutCardStates.indices.contains(cardIndex) {
                newState.currentExerciseAllSetsCompleted = true
                newState.workoutCardStates.forEach {
                    print("\($0.currentExerciseName), \( $0.allSetsCompleted)")
                }
            }
            
        case let .changeExerciseIndex(newIndex):
            newState.currentExerciseIndex = newIndex
            newState.updatingIndex = newIndex
            newState.currentWorkoutData = newState.workoutRoutine.workouts[newIndex]
            
        case let .setEditAndMemoViewPresented(presented):
            newState.isEditAndMemoViewPresented = presented
            
            // MARK: - 각 운동 종목 메모 업데이트
        case let .updateExerciseMemo(newMemo):
            let currentIndex = newState.currentExerciseIndex
            let currentExercise = newState.workoutCardStates[currentIndex]
            // 뷰에 반영
            newState.workoutCardStates[currentIndex].memoInExercise = newMemo
            
            let updatedWorkout = Workout(
                id: currentExercise.workoutID,
                documentID: newState.workoutRoutine.documentID,
                name: currentExercise.currentExerciseName,
                sets: currentExercise.setInfo,
                comment: newMemo
            )
            updateWorkoutUseCase.execute(uid: newState.uid, item: updatedWorkout)
            
        case let .stopRestTimer(isStopped):
            if isStopped {
                NotificationService.shared.removeRestNotification()
                newState.isResting = false
                newState.isRestTimerStopped = true
                newState.restRemainingTime = 0.0
                newState.restStartTime = nil
                newState.restStartDate = nil
            } else {
                newState.isResting = true
                newState.isRestTimerStopped = false
                newState.restRemainingTime = Float(newState.restTime)
                newState.restStartTime = nil
                newState.restStartDate = Date()
            }
            
            // MARK: - 루틴 메모 업데이트
        case let .updateRoutineMemo(with: newMemo):
            let placeholders = [
                String(localized: "메모를 입력해주세요."),
                "메모를 입력해주세요.",
                "Please enter a memo.",
                "メモを入力してください。"
            ]
            let trimmedMemo = newMemo?.trimmingCharacters(in: .whitespacesAndNewlines)
            let newComment = (trimmedMemo == nil || trimmedMemo == "" || placeholders.contains(trimmedMemo!)) ? nil : trimmedMemo
            
            let updatedWorkoutRecord = WorkoutRecord(
                rmID: newState.recordID,
                documentID: newState.workoutRecord.documentID,
                uuid: newState.recordID,
                workoutRoutine: newState.workoutRoutine,
                totalTime: newState.workoutTime,
                workoutTime: newState.workoutTime,
                comment: newComment,
                date: Date()
            )
            print("새로운 루틴 메모: \(String(describing: newComment))")
            
            updateRecordUseCase.execute(uid: uid, item: updatedWorkoutRecord)
            
        case let .setUpdatingIndex(cardIndex):
            newState.updatingIndex = cardIndex
            
        case let .setWorkoutStartDate(date):
            newState.workoutStartDate = date
            
        case let .setWorkoutTimeWhenBackgrounded(time):
            newState.accumulatedWorkoutTime = time
            newState.workoutTime = Int(time)
            
        case .setCurrentRoutineCompleted:
            newState.currentRoutineCompleted = true
            
        case let .setRestRemainingStartDate(date):
            newState.restStartDate = date
            
        case let .setRestRemainingTimeWhenBackgrounded(time):
            newState.accumulatedRestRemainingTime = time
            newState.restRemainingTime = Float(time)
            
            // MARK: - 변경된 운동 정보로 카드 업데이트
        case let .loadUpdatedRoutine(routines):
            if uid != nil {
                if let routine = routines
                    .first(where: { $0.documentID == currentState.workoutRoutine.documentID }) {
                    newState.workoutRoutine = routine
                    newState.workoutCardStates = updateCurrentWorkoutCard(
                        updatedRoutine: routine,
                        currentExerciseIndex: newState.currentExerciseIndex
                    )
                    newState.currentWorkoutData = routine.workouts[newState.currentExerciseIndex]
                }
            } else {
                if let routine = routines
                    .first(where: { $0.rmID == currentState.workoutRoutine.rmID }) {
                    newState.workoutRoutine = routine
                    newState.workoutCardStates = updateCurrentWorkoutCard(
                        updatedRoutine: routine,
                        currentExerciseIndex: newState.currentExerciseIndex
                    )
                    newState.currentWorkoutData = routine.workouts[newState.currentExerciseIndex]
                }
            }
        }//switch mutation
        return newState
    }//reduce
}
