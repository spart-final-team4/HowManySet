import Foundation
import RxSwift
import ReactorKit

final class RecordDetailViewReactor: Reactor {
    
    // MARK: - Action is an user interaction
    enum Action {
        case tapConfirm
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setDismiss(Bool)
    }
    
    // MARK: - State is a current view state
    struct State {
        let record: WorkoutRecord
        var shouldDismiss = false
    }

    // MARK: - Properties
    let initialState: State

    // MARK: - Init
    init(record: WorkoutRecord) {
        self.initialState = State(record: record)
    }
    
    // MARK: - Mutate(Action -> Mutation)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapConfirm:
            return .just(.setDismiss(true))
        }
    }

    // MARK: - Reduce(Mutation -> State)
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setDismiss(value):
            newState.shouldDismiss = value
        }
        return newState
    }
}
