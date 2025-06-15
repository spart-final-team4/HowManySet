import Foundation
import RxSwift
import ReactorKit

final class RoutineListViewReactor: Reactor {
    
    private let deleteRoutineUseCase: DeleteRoutineUseCase
    private let fetchRoutineUseCase: FetchRoutineUseCase
    private let saveRoutineUseCase: SaveRoutineUseCase
    
    // MARK: - Action is an user interaction
    enum Action {

    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {

    }
    
    // MARK: - State is a current view state
    struct State {

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

    }

    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {

    }
}
