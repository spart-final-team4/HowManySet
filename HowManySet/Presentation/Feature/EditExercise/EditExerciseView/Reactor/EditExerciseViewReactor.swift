//
//  EditExcerciseViewReactor.swift
//  HowManySet
//
//  Created by MJ Dev on 6/26/25.
//

import Foundation
import RxSwift
import RxRelay
import ReactorKit


final class EditExerciseViewReactor: Reactor {
    
    private let updateWorkoutUseCase: UpdateWorkoutUseCase
    
    enum Action {
        case saveExcerciseButtonTapped((name: String, weightSet: [[String]]))
        case changeUnit(String)
    }
    
    enum Mutation {
        case saveExcercise((name: String, weightSet: [[String]]))
        case changeUnit(String)
    }
    
    struct State {
        var workout: Workout
        var currentUnit: String = "kg"
    }
    
    /// 운동 저장 결과 상태
    enum ValidWorkout {
        case workoutNameTooLong
        case workoutNameTooShort
        case workoutInvalidCharacters
        case workoutNameEmpty
        case workoutContainsZero
        case workoutEmpty
        case workoutSetsEmpty
        case success
    }
    
    let alertRelay = PublishRelay<ValidWorkout>()
    var initialState: State
    let uid = FirebaseAuthService().fetchCurrentUser()?.uid
    
    init(workout: Workout,
         updateWorkoutUseCase: UpdateWorkoutUseCase
    ) {
        self.initialState = State(workout: workout,
                                  currentUnit: workout.sets[0].unit)
        self.updateWorkoutUseCase = updateWorkoutUseCase
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .saveExcerciseButtonTapped((let newName, let newWeightSet)):
            return .just(.saveExcercise((newName, newWeightSet)))
        case .changeUnit(let unit):
            return .just(.changeUnit(unit))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .saveExcercise((let newName, let newWeightSet)):
            var newWorkout = newState.workout
            newWorkout.name = newName
            newWorkout.sets = mappingSets(with: newWeightSet)
            if case .success = validationWorkout(workout: newWorkout) {
                updateWorkoutUseCase.execute(uid: uid, item: newWorkout)
            }
            alertRelay.accept(validationWorkout(workout: newWorkout))
        case .changeUnit(let unit):
            newState.currentUnit = unit
        }
        return newState
    }
    
    // MARK: - 유효성 검사
    private func validationWorkout(workout: Workout) -> ValidWorkout {
        if workout.name.isEmpty {
            return ValidWorkout.workoutNameEmpty
        }
        if workout.name.count > 25 {
            return ValidWorkout.workoutNameTooLong
        }
        if workout.name.count <= 1 {
            return ValidWorkout.workoutNameTooShort
        }
        if workout.sets.contains(where: { $0.reps == 0 || $0.weight == 0}) {
            return ValidWorkout.workoutContainsZero
        }
        if workout.sets.contains(where: { $0.reps < 0 || $0.weight < 0}) {
            return ValidWorkout.workoutInvalidCharacters
        }
        if workout.sets.isEmpty {
            return ValidWorkout.workoutSetsEmpty
        }
        
        return ValidWorkout.success
    }
    
    private func mappingSets(with array: [[String]]) -> [WorkoutSet] {
        var arr = array
        var newSets = [WorkoutSet]()
        arr.removeFirst()
        arr.forEach { element in
            newSets.append(WorkoutSet(weight: Double(element[0]) ?? -1,
                                      unit: currentState.currentUnit,
                                      reps: Int(element[1]) ?? -1))
        }
        return newSets
    }
}
