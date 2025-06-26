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
        case saveExcerciseButtonTapped
        case changeExcerciseWeightSet([[String]])
        case changeUnit(String)
    }
    
    enum Mutation {
        case saveExcercise
        case changeExcerciseWeightSet([[String]])
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
        case .saveExcerciseButtonTapped:
            return .just(.saveExcercise)
        case .changeExcerciseWeightSet(let newWeightSet):
            return .just(.changeExcerciseWeightSet(newWeightSet))
        case .changeUnit(let unit):
            return .just(.changeUnit(unit))
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
        }
        return newState
    }
    
}
