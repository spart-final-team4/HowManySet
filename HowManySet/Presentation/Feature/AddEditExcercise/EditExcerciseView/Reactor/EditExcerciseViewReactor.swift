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


final class EditExcerciseViewReactor: Reactor {
    
    enum Action {
        case saveExcerciseButtonTapped
        case changeExcerciseWeightSet([[String]])
        case changeUnit(String)
        case changeExcerciseName(String)
    }
    
    enum Mutation {
        case saveExcercise
        case changeExcerciseWeightSet([[String]])
        case changeUnit(String)
        case changeExcerciseName(String)
    }
    
    struct State {
        var workout: Workout
        var currentWorkoutName: String = ""
        var currentUnit: String = "kg"
    }
    
    var initialState: State
    
    init(workout: Workout) {
        self.initialState = State(workout: workout)
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .saveExcerciseButtonTapped:
            return .just(.saveExcercise)
        case .changeExcerciseWeightSet(let newWeightSet):
            return .just(.changeExcerciseWeightSet(newWeightSet))
        case .changeUnit(let unit):
            return .just(.changeUnit(unit))
        case .changeExcerciseName(let newName):
            return .just(.changeExcerciseName(newName))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .saveExcercise:
            break
        case .changeExcerciseWeightSet(let newWeightSet):
            var newSet: [WorkoutSet] = []
            for i in 1..<newWeightSet.count {
                let weightSet = newWeightSet[i]
                newSet.append(WorkoutSet(weight: Double(weightSet[0]) ?? 0.0,
                                         unit: currentState.currentUnit,
                                         reps: Int(weightSet[1]) ?? 1))
            }
            newState.workout.sets = newSet
        case .changeUnit(let unit):
            newState.currentUnit = unit
        case .changeExcerciseName(let newName):
            newState.currentWorkoutName = newName
        }
        return newState
    }
    
}
