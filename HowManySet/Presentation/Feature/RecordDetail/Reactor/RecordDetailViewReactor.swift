import Foundation
import RxSwift
import ReactorKit

final class RecordDetailViewReactor: Reactor {
    
    // MARK: - Action is an user interaction
    enum Action {
        case tapConfirm
        case updateMemo(String?)
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setDismiss(Bool)
        case setMemo(String?)
    }
    
    // MARK: - State is a current view state
    struct State {
        let record: WorkoutRecord
        var memo: String?
        var shouldDismiss: Bool
    }

    // MARK: - Properties
    let initialState: State

    // MARK: - Init
    init(record: WorkoutRecord) {
        self.initialState = State(
            record: record,
            memo: record.comment,
            shouldDismiss: false
        )
    }
    
    // MARK: - Mutate(Action -> Mutation)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapConfirm:
            return .just(.setDismiss(true))
        case let .updateMemo(text):
            return .just(.setMemo(text))
        }
    }

    // MARK: - Reduce(Mutation -> State)
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setDismiss(value):
            newState.shouldDismiss = value
        case let .setMemo(text):
            newState.memo = text
        }
        return newState
    }
}
