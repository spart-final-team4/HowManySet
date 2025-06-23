import Foundation
import RxSwift
import ReactorKit

final class RoutineListViewReactor: Reactor {
    
    private let deleteRoutineUseCase: DeleteRoutineUseCase
    private let fetchRoutineUseCase: FetchRoutineUseCase
    private let saveRoutineUseCase: SaveRoutineUseCase

    var publicSaveRoutineUseCase: SaveRoutineUseCase { saveRoutineUseCase }

    // MARK: - Action is an user interaction
    enum Action {
        case viewWillAppear
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case updatedRoutine([WorkoutRoutine])
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
            return fetchRoutineUseCase.execute()
                .map{ Mutation.updatedRoutine($0) }
                .asObservable()
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
                    deleteRoutineUseCase.execute(item: routines[i])
                }
            }
            
            newState.routines = newRoutines
        }
        
        return newState
    }
}
