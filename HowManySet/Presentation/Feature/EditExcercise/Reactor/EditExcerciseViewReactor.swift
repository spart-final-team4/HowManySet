//
//  EditExcerciseViewReactor.swift
//  HowManySet
//
//  Created by 정근호 on 6/4/25.
//

import Foundation
import RxSwift
import ReactorKit

final class EditExcerciseViewReactor: Reactor {
    
    // Action is an user interaction
    enum Action {
        
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        
    }
    
    // State is a current view state
    struct State {
        
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
    }
    
    //    // Action -> Mutation
    //    func mutate(action: Action) -> Observable<Mutation> {
    //
    //    }
    //
    //    // Mutation -> State
    //    func reduce(state: State, mutation: Mutation) -> State {
    //
    //    }
}
