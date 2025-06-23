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
    
    private let saveRoutineUseCase: SaveRoutineUseCase
    private let deleteRoutineUseCase: DeleteRoutineUseCase
    // Action is an user interaction
    enum Action {
        case viewDidLoad
        case cellButtonTapped(IndexPath)
        case changeWorkoutInfo
        case removeSelectedWorkout
        case changeListOrder
        case plusExcerciseButtonTapped
        case reorderWorkout(source: IndexPath, destination: IndexPath)
    }
    
    // Mutate is a state mani
    enum Mutation {
        case loadWorkout
        case cellButtonTapped(IndexPath)
        case changeWorkoutInfo
        case removeSelectedWorkout
        case changeListOrder
        case plusExcerciseButtonTapped
        case reorderRoutine(WorkoutRoutine)
    }
    
    // State is a current view state
    struct State {
        var routine: WorkoutRoutine
        var currentSeclectedWorkout: Workout?
        var currentSeclectedIndexPath: IndexPath?
    }
    
    let initialState: State
    
    init(with routine: WorkoutRoutine,
         saveRoutineUseCase: SaveRoutineUseCase,
         deleteRoutineUseCase: DeleteRoutineUseCase
    ) {
        self.initialState = State(routine: routine)
        self.saveRoutineUseCase = saveRoutineUseCase
        self.deleteRoutineUseCase = deleteRoutineUseCase
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .just(.loadWorkout)
        case .cellButtonTapped(let indexPath):
            return .just(.cellButtonTapped(indexPath))
        case .changeWorkoutInfo:
            return .just(.changeWorkoutInfo)
        case .removeSelectedWorkout:
            return .just(.removeSelectedWorkout)
        case .changeListOrder:
            return .just(.changeListOrder)
        case .plusExcerciseButtonTapped:
            return .just(.plusExcerciseButtonTapped)
        case .reorderWorkout(source: let source, destination: let destination):
            var new = currentState.routine
            new.workouts.swapAt(source.item, destination.item)
            deleteRoutineUseCase.execute(item: currentState.routine)
            return .just(.reorderRoutine(new))
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadWorkout:
            break
        case .cellButtonTapped(let indexPath):
            newState.currentSeclectedWorkout = newState.routine.workouts[indexPath.row]
            newState.currentSeclectedIndexPath = indexPath
        case .changeWorkoutInfo:
            break
        case .removeSelectedWorkout:
            var newRoutine = newState.routine
            guard let workout = currentState.currentSeclectedWorkout else { return newState }
            deleteRoutineUseCase.execute(item: currentState.routine)
            guard let indexPath = currentState.currentSeclectedIndexPath else { return newState }
            newRoutine.workouts.remove(at: indexPath.row)
            saveRoutineUseCase.execute(item: newRoutine)
            newState.routine = newRoutine
        case .changeListOrder:
            break
        case .plusExcerciseButtonTapped:
            break
        case .reorderRoutine(let routine):
            var newRoutine = routine
            saveRoutineUseCase.execute(item: routine)
        }
        return newState
    }
}

