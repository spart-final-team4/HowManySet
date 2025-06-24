import Foundation
import RxSwift
import ReactorKit

final class RoutineListViewReactor: Reactor {
    
    private let deleteRoutineUseCase: DeleteRoutineUseCase
    private let fetchRoutineUseCase: FetchRoutineUseCase
    private let saveRoutineUseCase: SaveRoutineUseCase

    // MARK: - Action is an user interaction
    enum Action {
        case viewWillAppear
        case deleteRoutine(IndexPath)
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case updatedRoutine([WorkoutRoutine])
        case deleteRoutineAt(IndexPath)
    }
    
    // MARK: - State is a current view state
    struct State {
        var routines: [WorkoutRoutine] = []
    }
    
    let initialState: State
    
    init(deleteRoutineUseCase: DeleteRoutineUseCase, fetchRoutineUseCase: FetchRoutineUseCase, saveRoutineUseCase: SaveRoutineUseCase) {
        
        self.deleteRoutineUseCase = deleteRoutineUseCase
        self.fetchRoutineUseCase = fetchRoutineUseCase
        self.saveRoutineUseCase = saveRoutineUseCase
        self.initialState = State()
    }

    
    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchRoutineUseCase.execute(uid: UUID().uuidString)
                .map{ Mutation.updatedRoutine($0) }
                .asObservable()

        case let .deleteRoutine(indexPath):
            let routine = currentState.routines[indexPath.section]
            deleteRoutineUseCase.execute(uid: UUID().uuidString, item: routine)
            return .just(.deleteRoutineAt(indexPath))
        }
    }

    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updatedRoutine(let routines):
            var newRoutines: [WorkoutRoutine] = []
            for i in 0..<routines.count {
                if !routines[i].workouts.isEmpty {
                    newRoutines.append(routines[i])
                } else {
                    deleteRoutineUseCase.execute(uid: UUID().uuidString, item: routines[i])
                }
            }
            newState.routines = newRoutines

        case let .deleteRoutineAt(indexPath):
            var updated = state.routines
            updated.remove(at: indexPath.section)
            newState.routines = updated
        }

        return newState
    }
}
