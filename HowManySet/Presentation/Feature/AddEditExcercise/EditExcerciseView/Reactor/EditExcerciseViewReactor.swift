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
    
    private let updateWorkoutUseCase: UpdateWorkoutUseCaseProtocol
    
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
    
    var initialState: State
    
    init(workout: Workout,
         updateWorkoutUseCase: UpdateWorkoutUseCaseProtocol
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
            break
        case .changeUnit(let unit):
            newState.currentUnit = unit
        }
        return newState
    }
    
}
