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
    private let updateRoutineUseCase: UpdateRoutineUseCase
    private let deleteWorkoutUseCase: DeleteWorkoutUseCase
    private let fetchRoutineUseCase: FetchRoutineUseCase
    private let disposeBag = DisposeBag()
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
        case loadWorkout([WorkoutRoutine])
        case cellButtonTapped(IndexPath)
        case changeWorkoutInfo
        case removeSelectedWorkout
        case changeListOrder
        case plusExcerciseButtonTapped
        case reorderRoutine(source: IndexPath, destination: IndexPath)
    }
    
    // State is a current view state
    struct State {
        var routine: WorkoutRoutine
        var currentSeclectedWorkout: Workout?
        var currentSeclectedIndexPath: IndexPath?
    }
    
    let initialState: State
    private let uid = FirebaseAuthService().fetchCurrentUser()?.uid
    
    init(with routine: WorkoutRoutine,
         saveRoutineUseCase: SaveRoutineUseCase,
         fetchRoutineUseCase: FetchRoutineUseCase,
         deleteRoutineUseCase: DeleteRoutineUseCase,
         updateRoutineUseCase: UpdateRoutineUseCase,
         deleteWorkoutUseCase: DeleteWorkoutUseCase
    ) {
        self.initialState = State(routine: routine)
        self.fetchRoutineUseCase = fetchRoutineUseCase
        self.saveRoutineUseCase = saveRoutineUseCase
        self.deleteRoutineUseCase = deleteRoutineUseCase
        self.updateRoutineUseCase = updateRoutineUseCase
        self.deleteWorkoutUseCase = deleteWorkoutUseCase
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return fetchRoutineUseCase.execute(uid: uid)
                .map{ Mutation.loadWorkout($0) }
                .asObservable()
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
            guard source != destination,
                  source.row < currentState.routine.workouts.count,
                  destination.row < currentState.routine.workouts.count
            else { return .empty() }
            return .just(.reorderRoutine(source: source, destination: destination))
                .observe(on: MainScheduler.asyncInstance)
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadWorkout(let routines):
            routines.forEach { routine in
                if routine.rmID == currentState.routine.rmID {
                    newState.routine = routine
                }
            }
        case .cellButtonTapped(let indexPath):
            newState.currentSeclectedWorkout = newState.routine.workouts[indexPath.row]
            newState.currentSeclectedIndexPath = indexPath
        case .changeWorkoutInfo:
            break
        case .removeSelectedWorkout:
            var newRoutine = newState.routine
            guard let workout = currentState.currentSeclectedWorkout else { return newState }
            deleteWorkoutUseCase.execute(uid: uid, item: workout)
            guard let indexPath = currentState.currentSeclectedIndexPath else { return newState }
            newRoutine.workouts.remove(at: indexPath.row)
            newState.routine = newRoutine
        case .changeListOrder:
            break
        case .plusExcerciseButtonTapped:
            break
        case .reorderRoutine(let source, let destination):
            break
            // TODO: 마이너 패치로 들어감
//            var newRoutine = state.routine
//            var sourceItem = newRoutine.workouts[source.row]
//            var destinationItem = newRoutine.workouts[destination.row]
//            
//            newRoutine.workouts[source.row] = destinationItem
//            newRoutine.workouts[destination.row] = sourceItem
//            updateRoutineUseCase.execute(item: newRoutine)
//            newState.routine = newRoutine
        }
        return newState
    }
    
    func deleteWorkout(item: Workout) {
//        let uid = FirebaseAuthService().fetchCurrentUser()?.uid
//        if let uid = uid {
//            fsDeleteWorkoutUseCase.execute(uid: uid, item: item)
//        } else {
//            deleteRoutineUseCase.execute(item: item)
//        }
    }
}

