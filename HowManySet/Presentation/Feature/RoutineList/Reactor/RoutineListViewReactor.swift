import Foundation
import RxSwift
import ReactorKit

final class RoutineListViewReactor: Reactor {
    
    private let deleteRoutineUseCase: DeleteRoutineUseCase
    private let fetchRoutineUseCase: FetchRoutineUseCase
    private let saveRoutineUseCase: SaveRoutineUseCase
    
    // MARK: - Action is an user interaction
    enum Action {
        case viewDidLoad
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setRoutines([WorkoutRoutine])
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
        case .viewDidLoad:
            return Observable.just(.setRoutines(WorkoutRoutine.mockData))
        }
    }

    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setRoutines(routines):
            newState.routines = routines
        }

        return newState
    }
}
