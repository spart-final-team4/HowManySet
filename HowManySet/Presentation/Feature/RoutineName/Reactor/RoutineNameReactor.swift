import Foundation
import RxSwift
import ReactorKit

final class RoutineNameReactor: Reactor {

    // MARK: - Action is an user interaction
    enum Action {
        case setRoutineName(String)
    }

    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setRoutineName(String)
    }

    // MARK: - State is a current view state
    struct State {
        var routineName: String = ""
    }

    let initialState: State

    // MARK: - Init
    init() {
        self.initialState = State()
    }

    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setRoutineName(name):
            return .just(.setRoutineName(name))
        }
    }

    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setRoutineName(name):
            newState.routineName = name
        }
        return newState
    }
}
