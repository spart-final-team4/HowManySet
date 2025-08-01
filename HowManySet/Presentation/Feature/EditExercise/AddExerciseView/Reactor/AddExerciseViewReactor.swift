//
//  AddExerciseViewReactor.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift
import RxRelay
import ReactorKit

/// 운동 편집 화면의 상태를 관리하는 Reactor 클래스입니다.
///
/// 사용자의 입력(Action)을 받아 상태(State)를 업데이트하고,
/// 그에 따른 변경사항(Mutation)을 처리합니다.
///
/// 주요 기능:
/// - 새로운 운동 세트 추가
/// - 루틴 저장 처리
/// - 운동 이름, 단위, 세트 정보 변경 처리
/// - 유효성 검사 및 알림 처리
final class AddExerciseViewReactor: Reactor {
    
    // MARK: - Action
    
    /// 사용자의 인터랙션을 정의합니다.
    enum Action {
        case addExcerciseButtonTapped         // 운동 추가 버튼 클릭
        case saveRoutineButtonTapped          // 루틴 저장 버튼 클릭
        case changeExerciseName(String)       // 운동 이름 변경
        case changeUnit(String)               // 단위 변경 (kg, lbs 등)
        case changeExcerciseWeightSet([[String]]) // 세트 정보 변경 (무게, 반복 수)
    }
    
    // MARK: - Mutation
    
    /// 상태를 변경하는 내부 동작입니다.
    enum Mutation {
        case addExcercise(Workout)            // 새로운 운동 추가
        case saveRoutine                      // 루틴 저장
        case changeExcerciseName(String)      // 운동 이름 갱신
        case changeUnit(String)               // 단위 갱신
        case changeExcerciseWeightSet([[String]]) // 세트 정보 갱신
    }
    
    // MARK: - State
    
    /// 뷰의 현재 상태를 나타냅니다.
    struct State {
        var currentRoutine: WorkoutRoutine    // 현재 작성 중인 루틴
        var currentExcerciseName: String = "" // 입력된 운동 이름
        var currentUnit: String = "kg"        // 단위 기본값 (kg)
        var currentWeightSet: [[String]] = []    // 현재 세트 입력값 (2차원 배열: [무게, 반복수])
        
        // 홈 화면 관련 데이터
        var caller: ViewCaller
        var workoutStateForEdit: WorkoutStateForEdit?
    }
    
    /// 운동 저장 결과 상태
    enum ValidWorkout {
        case workoutNameTooLong
        case workoutNameTooShort
        case workoutInvalidCharacters
        case workoutNameEmpty
        case workoutContainsZero
        case workoutEmpty
        case success
    }
    
    // MARK: - Properties
    
    let initialState: State
    let alertRelay = PublishRelay<ValidWorkout>() // Alert 표시용 Relay
    let dismissRelay = PublishRelay<Void>()       // 화면 종료용 Relay
    
    private let saveRoutineUseCase: SaveRoutineUseCaseProtocol
    private let uid = FirebaseAuthService().fetchCurrentUser()?.uid
    // MARK: - Initializer
    
    /// 초기화 메서드
    /// - Parameters:
    ///   - routineName: 새로 생성할 루틴 이름
    ///   - saveRoutineUseCase: 루틴 저장을 위한 UseCase 주입
    init(routineName: String,
         saveRoutineUseCase: SaveRoutineUseCaseProtocol,
         workoutStateForEdit: WorkoutStateForEdit?,
         caller: ViewCaller
    ) {
        self.saveRoutineUseCase = saveRoutineUseCase
        self.initialState = State(
            currentRoutine: WorkoutRoutine(
                rmID: UUID().uuidString,
                documentID: UUID().uuidString,
                name: routineName,
                workouts: []
            ),
            caller: caller,
            workoutStateForEdit: workoutStateForEdit ?? nil
        )

    }
    
    // MARK: - Mutation 생성
    
    /// 사용자 Action을 기반으로 Mutation을 생성합니다.
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .addExcerciseButtonTapped:
            return Observable<Mutation>.create { [unowned self] observer in
                var currentWeightSet = self.currentState.currentWeightSet
                currentWeightSet.removeFirst() // 첫 행은 빈 값이므로 제거
                
                let sets = currentWeightSet.map {
                    WorkoutSet(
                        weight: Double($0[0]) ?? 0.0,
                        unit: self.currentState.currentUnit,
                        reps: Int($0[1]) ?? 0)
                }
                
                let newWorkout = Workout(
                    id: UUID().uuidString,
                    name: self.currentState.currentExcerciseName,
                    sets: sets,
                    comment: nil
                )
                
                if case .success = self.validationWorkout(workout: newWorkout) {
                    observer.onNext(.addExcercise(newWorkout))
                }
                observer.onCompleted()
                
                DispatchQueue.main.async {
                    self.alertRelay.accept(self.validationWorkout(workout: newWorkout))
                }
                
                return Disposables.create()
            }
            
        case .saveRoutineButtonTapped:
            return Observable.create { [unowned self] observer in
                let routine = self.currentState.currentRoutine
                if routine.workouts.isEmpty {
                    self.alertRelay.accept(.workoutEmpty)
                } else {
                    self.dismissRelay.accept(())
                    observer.onNext(.saveRoutine)
                }
                observer.onCompleted()
                return Disposables.create()
            }
            
        case .changeExerciseName(let name):
            return .just(.changeExcerciseName(name))
            
        case .changeUnit(let unit):
            return .just(.changeUnit(unit))
            
        case .changeExcerciseWeightSet(let newWeightSet):
            return .just(.changeExcerciseWeightSet(newWeightSet))
        }
    }
    
    // MARK: - 상태 갱신
    
    /// Mutation을 통해 상태를 업데이트합니다.
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .addExcercise(let workout):
            newState.currentRoutine.workouts.append(workout)
            
        case .saveRoutine:
            saveRoutineUseCase.execute(uid: uid, item: newState.currentRoutine)
            
        case .changeExcerciseName(let newName):
            newState.currentExcerciseName = newName
            
        case .changeUnit(let unit):
            newState.currentUnit = unit
            
        case .changeExcerciseWeightSet(let newWeightSet):
            newState.currentWeightSet = newWeightSet
        }
        return newState
    }
    
    // MARK: - 유효성 검사
    func validationWorkout(workout: Workout) -> ValidWorkout {
        if workout.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return ValidWorkout.workoutNameEmpty
        }
        if workout.name.count > 25 {
            return ValidWorkout.workoutNameTooLong
        }
        if workout.name.count <= 1 {
            return ValidWorkout.workoutNameTooShort
        }
        if workout.sets.contains(where: { $0.reps < 0 || $0.weight < 0}) {
            return ValidWorkout.workoutInvalidCharacters
        }
        
        return ValidWorkout.success
    }
}
