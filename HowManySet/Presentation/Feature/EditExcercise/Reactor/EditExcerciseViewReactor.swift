//
//  EditExcerciseViewReactor.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift
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
        case addExcercise
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
    
    let initialState: State
    
    init(routineName: String) {
        self.initialState = State(currentRoutine: WorkoutRoutine(name: routineName, workouts: []))
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .addExcerciseButtonTapped:
            return .just(.addExcercise)
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
        case .addExcercise:
            print(newState.currentRoutine.name)
        case .saveRoutine:
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
}
