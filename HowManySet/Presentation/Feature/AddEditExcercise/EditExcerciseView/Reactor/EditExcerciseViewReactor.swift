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

    }
    
    enum Mutation {

    }
    
    struct State {
        var workout: Workout
    }
    
    var initialState: State
    
    init(workout: Workout) {
        self.initialState = State(workout: workout)
    }
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}
