//
//  HomeViewReactor+Extension.swift
//  HowManySet
//
//  Created by 정근호 on 7/21/25.
//

import Foundation
import RxSwift
import ReactorKit

extension HomeViewReactor {
    
    /// 휴식시간 타이머: 현재 0.05초 간격으로 진행
    func makeRestTimer(_ restTime: Float) -> Observable<HomeViewReactor.Mutation> {
        let tickCount = restTime * 20
        return Observable<Int>.interval(.milliseconds(50), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .take(Int(tickCount))
            .take(until: self.state.map {
                $0.isRestPaused || !$0.isResting || $0.isRestTimerStopped }
                .filter { $0 }
            )
            .map { _ in Mutation.restRemainingUpdating }
            .observe(on: MainScheduler.instance)
    }
    
    // MARK: - handleWorkoutFlow
    /// 스킵(다음) 버튼 클릭 시 mutate내에서 실행되는 전반적인 기능 로직
    func handleWorkoutFlow(
        _ cardIndex: Int,
        isResting: Bool,
        restTime: Float
    ) -> Observable<HomeViewReactor.Mutation> {
        
        let nextSetIndex = currentState.workoutCardStates[cardIndex].setIndex + 1
        let currentWorkout = currentState.workoutRoutine.workouts[cardIndex]
        var currentCardState = currentState.workoutCardStates[cardIndex]
        
        // 휴식 타이머
        var restTimer: Observable<HomeViewReactor.Mutation> = .empty()
        
        if isResting {
            let restTime = currentState.restTime
            let tickCount = restTime * 20 // 0.05초 간격으로 진행
            // 휴식 타이머
            restTimer = makeRestTimer(tickCount)
            if restTime > 0 {
                NotificationService.shared.scheduleRestFinishedNotification(seconds: TimeInterval(restTime))
            }
        }
        
        // 다음 세트가 있는 경우 (휴식 시작)
        // 해당 상태에서 Forward 버튼을 누르면 휴식 스킵
        if nextSetIndex < currentCardState.totalSetCount {
            let nextSet = currentWorkout.sets[nextSetIndex]
            currentCardState.setIndex = nextSetIndex
            currentCardState.currentSetNumber = nextSetIndex + 1
            currentCardState.setProgressAmount = nextSetIndex
            currentCardState.currentWeight = nextSet.weight
            currentCardState.currentUnit = nextSet.unit
            currentCardState.currentReps = nextSet.reps
            
            /// 변경된 카드 State!
            let updatedCardState = currentCardState
            
            return .concat([
                .just(.manageWorkoutCount(isCurrentExerciseCompleted: false)),
                .just(.setResting(isResting)),
                // 카드 정보 업데이트
                .just(.updateWorkoutCardState(updatedCardState: updatedCardState)),
                .just(.setRestTimeDataAtProgressBar(restTime)),
                restTimer
            ])
            .observe(on: MainScheduler.instance)
        } else { // 현재 운동의 모든 세트 완료(카드 삭제), 다음 운동으로 이동 또는 루틴 종료
            var nextExerciseIndex = currentState.workoutCardStates.indices.contains(cardIndex) ? cardIndex : 0
            var currentCardState = currentState.workoutCardStates[cardIndex]
            currentCardState.setProgressAmount += 1
            
            // 다음,이전 인덱스가 존재하고 다음,이전 카드 모든 세트 완료 시
            // 뷰 제거시에 나중에 운동완료시 WorkoutCardStates를 쓸 수도 있으니 뷰만 삭제되도록 하였음.
            if currentState.workoutCardStates.indices.contains(cardIndex + 1),
               !currentState.workoutCardStates[cardIndex + 1].allSetsCompleted {
                nextExerciseIndex += 1
            } else if currentState.workoutCardStates.indices.contains(cardIndex - 1),
                      !currentState.workoutCardStates[cardIndex - 1].allSetsCompleted {
                nextExerciseIndex -= 1
            }
            
            if nextExerciseIndex != cardIndex {
                return .concat([
                    .just(.setResting(isResting)),
                    .just(.setTrueCurrentCardViewCompleted(at: cardIndex)),
                    .just(.updateWorkoutCardState(
                        updatedCardState: currentCardState,
                        oldCardState: nil,
                        oldCardIndex: nil)),
                    .just(.setRestTimeDataAtProgressBar(restTime)),
                    restTimer
                ])
                .observe(on: MainScheduler.instance)
            } else { // nextExerciseIndex == cardIndex일때
                
                currentCardState.setProgressAmount += 1
                let updatedCardState = currentCardState
                return .concat([
                    .just(.setResting(isResting)),
                    // 카드 정보 업데이트
                    .just(.updateWorkoutCardState(updatedCardState: updatedCardState)),
                    .just(.setTrueCurrentCardViewCompleted(at: cardIndex))
                ])
                .observe(on: MainScheduler.instance)
            }
            
        }
    }
    
    // MARK: - convertWorkoutCardStatesToWorkouts
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
    //       return state
    //    }
    //    return nil
    //}
}

// MARK: - LiveActivity State
extension HomeViewReactor.State {
    var forLiveActivity: WorkoutDataForLiveActivity {
        guard workoutCardStates.indices.contains(currentExerciseIndex) else {
            return createDefaultLiveActivityData()
        }

        let exercise = workoutCardStates[currentExerciseIndex]

        return WorkoutDataForLiveActivity(
            workoutTime: workoutTime,
            isWorkingout: isWorkingout,
            isWorkoutPaused: isWorkoutPaused,
            exerciseName: exercise.currentExerciseName,
            exerciseInfo: formatExerciseInfo(exercise),
            currentRoutineCompleted: currentRoutineCompleted,
            restStartDate: liveRestStartDate,
            restTime: liveRestTime - 1,
            isResting: isResting,
            isRestPaused: isRestPaused,
            currentSet: exercise.setProgressAmount,
            totalSet: exercise.totalSetCount,
            currentIndex: currentExerciseIndex
        )
    }

    private func createDefaultLiveActivityData() -> WorkoutDataForLiveActivity {
        WorkoutDataForLiveActivity(
            workoutTime: 0,
            isWorkingout: true,
            isWorkoutPaused: false,
            exerciseName: "",
            exerciseInfo: "",
            currentRoutineCompleted: false,
            restStartDate: nil,
            restTime: 0,
            isResting: false,
            isRestPaused: false,
            currentSet: 0,
            totalSet: 0,
            currentIndex: 0
        )
    }

    private func formatExerciseInfo(_ exercise: WorkoutCardState) -> String {
        let reps = exercise.currentRepsForSave
        let weight = formatWeight(Float(exercise.currentWeightForSave))
        let unit = exercise.currentUnitForSave
        let repsText = String(localized: "회")

        return "\(weight)\(unit) X \(reps)\(repsText)"
    }

    private func formatWeight(_ weight: Float) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(weight)) : String(weight)
    }
}


// MARK: InitialState 관련
extension HomeViewReactor {
    
    /// 운동 편집 뷰에서 받아온 WorkoutRoutine을 가지고 있는 InitialState
    static func fetchedInitialState(routine: WorkoutRoutine) -> State {
        // 루틴 선택 시 초기 값 설정
        let initialRoutine = routine
        // 초기 운동 카드 뷰들 state 초기화
        var initialWorkoutCardStates: [WorkoutCardState] = []
        /// 루틴 전체의 세트 수
        var initialTotalSetCountInRoutine = 0
        // 현재 루틴의 모든 정보를 workoutCardStates에 저장
        for (i, workout) in initialRoutine.workouts.enumerated() {
            initialWorkoutCardStates.append(WorkoutCardState(
                workoutID: workout.id,
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
            rmID:  UUID().uuidString,
            documentID: routine.documentID,
            uuid: UUID().uuidString,
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
        
        // Firebase uid
        let uid = FirebaseAuthService().fetchCurrentUser()?.uid
        
        return State(
            workoutRoutine: initialRoutine,
            workoutCardStates: initialWorkoutCardStates,
            currentExerciseIndex: 0,
            updatingIndex: 0,
            isWorkingout: true,
            isWorkoutPaused: false,
            workoutTime: 0,
            isResting: false,
            isRestPaused: false,
            restRemainingTime: 60.0,
            restTime: 60.0, // 기본 60초로 설정
            restStartTime: nil,
            date: Date(),
            memoInRoutine: initialWorkoutRecord.comment,
            currentExerciseAllSetsCompleted: false,
            isEditAndMemoViewPresented: false,
            isRestTimerStopped: false,
            workoutRecord: initialWorkoutRecord,
            workoutSummary: initialWorkoutSummary,
            totalExerciseCount: initialWorkoutCardStates.count,
            didExerciseCount: 0,
            totalSetCountInRoutine: initialTotalSetCountInRoutine,
            didSetCount: 0,
            currentWorkoutData: initialRoutine.workouts[0],
            workoutStartDate: Date(),
            currentRoutineCompleted: false,
            uid: uid,
            documentID: initialRoutine.documentID,
            recordID: "",
            liveRestStartDate: nil,
            liveRestTime: 60,
        )
    }
    
    /// 운동 편집 시 해당 운동카드 변경
    func updateCurrentWorkoutCard(
        updatedRoutine: WorkoutRoutine,
        currentExerciseIndex: Int) -> [WorkoutCardState]
    {
        let currentWorkoutCard = currentState.workoutCardStates[currentExerciseIndex]
        let currentSetIndex = currentWorkoutCard.setIndex
        let currentProgressAmount = currentWorkoutCard.setProgressAmount
        var updatedWorkoutCard: WorkoutCardState
        var updatedWorkoutCardStates = currentState.workoutCardStates
        if let workout = updatedRoutine.workouts.first(where: { currentWorkoutCard.workoutID == $0.id }) {
            let newSetCount = workout.sets.count
            // newProgressAmount = 기존 값 그대로 유지, 단 총 세트수 넘으면 보정
            let newProgressAmount = min(currentProgressAmount, newSetCount)
            let newSetIndex = min(currentSetIndex, newSetCount - 1)
            let allSetsCompleted = (newProgressAmount >= newSetCount)
            updatedWorkoutCard = WorkoutCardState(
                workoutID: workout.id,
                currentExerciseName: workout.name,
                currentWeight: workout.sets[newSetIndex].weight,
                currentUnit: workout.sets[newSetIndex].unit,
                currentReps: workout.sets[newSetIndex].reps,
                setInfo: workout.sets,
                setIndex: newSetIndex,
                exerciseIndex: currentWorkoutCard.exerciseIndex,
                totalExerciseCount: currentState.totalExerciseCount,
                totalSetCount: workout.sets.count,
                currentExerciseNumber: currentWorkoutCard.currentExerciseNumber,
                currentSetNumber: newSetIndex+1,
                setProgressAmount: newProgressAmount,
                memoInExercise: workout.comment,
                allSetsCompleted: allSetsCompleted
            )
            updatedWorkoutCardStates[currentExerciseIndex] = updatedWorkoutCard
        }
        return updatedWorkoutCardStates
    }
}
