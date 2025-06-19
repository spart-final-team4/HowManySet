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
            let trimmedCurrent = currentState.memo?.trimmingCharacters(in: .whitespacesAndNewlines)
            let current = (trimmedCurrent == "메모를 입력해주세요.") ? nil : trimmedCurrent
            let original = currentState.record.comment?.trimmingCharacters(in: .whitespacesAndNewlines)

            let isCurrentEmpty = current?.isEmpty ?? true
            let isOriginalEmpty = original?.isEmpty ?? true

            // 둘 다 nil 또는 공백이면 변경 없음
            if isCurrentEmpty && isOriginalEmpty {
                print("변경된 값 없음")
                return .just(.setDismiss(true))
            }

            // 값이 다르면 변경된 것으로 간주
            if current != original {
                print("변경된 메모 저장: \(current ?? "")")
                return .just(.setDismiss(true))
            }

            print("변경된 값 없음")
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
