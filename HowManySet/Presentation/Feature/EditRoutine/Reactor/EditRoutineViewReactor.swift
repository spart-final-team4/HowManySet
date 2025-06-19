//
//  AddRoutineViewModel.swift
//  HowManySet
//
//  Created by MJ Dev on 5/30/25.
//

import Foundation
import RxSwift
import ReactorKit

final class EditRoutineViewReactor: Reactor {
    
    // Action is an user interaction
    enum Action {
        case viewDidLoad
    }
    
    // Mutate is a state mani
    enum Mutation {
        case loadWorkout
    }
    
    // State is a current view state
    struct State {
        var routine: WorkoutRoutine
    }
    
    let initialState: State
    
    init(with routine: WorkoutRoutine) {
        self.initialState = State(routine: routine)
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .just(.loadWorkout)
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadWorkout:
            break
        }
        return newState
    }
}
