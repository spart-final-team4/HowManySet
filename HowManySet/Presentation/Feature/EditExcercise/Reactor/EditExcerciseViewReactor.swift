//
//  EditExcerciseViewReactor.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift
import RxRelay
import ReactorKit

final class EditExcerciseViewReactor: Reactor {
    
    // Action is an user interaction
    enum Action {
        case addExcerciseButtonTapped
        case saveRoutineButtonTapped
        case changeExerciseName(String)
        case changeUnit(String)
        case changeExcerciseWeightSet([[Int]])
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case addExcercise(Workout)
        case saveRoutine
        case changeExcerciseName(String)
        case changeUnit(String)
        case changeExcerciseWeightSet([[Int]])
    }
    
    // State is a current view state
    struct State {
        var currentRoutine: WorkoutRoutine
        var currentExcerciseName: String = ""
        var currentUnit: String = "kg"
        var currentWeightSet: [[Int]] = []
    }
    
    enum VaildWorkout {
        case success
        case failure
    }
    let initialState: State
    let alertRelay = PublishRelay<VaildWorkout>()
    
    init(routineName: String) {
        self.initialState = State(currentRoutine: WorkoutRoutine(name: routineName, workouts: []))
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .addExcerciseButtonTapped:
            return Observable<Mutation>.create { [unowned self] observer in
                var currentWeightSet = self.currentState.currentWeightSet
                currentWeightSet.removeFirst()
                let sets = currentWeightSet.map{
                    WorkoutSet(weight: Double($0[0]),
                               unit: self.currentState.currentUnit,
                               reps: $0[1])
                }
                let newWorkout = Workout(name: self.currentState.currentExcerciseName,
                                         sets: sets,
                                         comment: nil)
                
                if self.validationWorkout(workout: newWorkout) {
                    observer.onNext(.addExcercise(newWorkout))
                    self.alertRelay.accept(.success)
                } else {
                    self.alertRelay.accept(.failure)
                }
                observer.onCompleted()
                return Disposables.create()
            }
        case .saveRoutineButtonTapped:
            return .just(.saveRoutine)
        case .changeExerciseName(let name):
            return .just(.changeExcerciseName(name))
        case .changeUnit(let unit):
            return .just(.changeUnit(unit))
        case .changeExcerciseWeightSet(let newWeightSet):
            return .just(.changeExcerciseWeightSet(newWeightSet))
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .addExcercise(let workout):
            newState.currentRoutine.workouts.append(workout)
        case .saveRoutine:
            // TODO: Realm Routine 저장
            print(newState.currentRoutine)
        case .changeExcerciseName(let newName):
            print(newName)
            newState.currentExcerciseName = newName
        case .changeUnit(let unit):
            print(unit)
            newState.currentUnit = unit
        case .changeExcerciseWeightSet(let newWeightSet):
            newState.currentWeightSet = newWeightSet
            print(newWeightSet)
        }
        return newState
    }
    
    func validationWorkout(workout: Workout) -> Bool {
        if workout.name == "" || workout.sets.filter{ $0.reps < 0 || $0.weight < 0 }.count > 0 {
            return false
        }
        return true
    }
}
