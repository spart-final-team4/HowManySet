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
    }
    
    enum Mutation {
        case saveExcercise
        case changeExcerciseWeightSet([[String]])
    }
    
    struct State {
        var workout: Workout
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .saveExcercise:
            break
        case .changeExcerciseWeightSet(let newWeightSet):
            print(newWeightSet)
        }
        return newState
    }
}
