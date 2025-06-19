import Foundation
import RxSwift
import ReactorKit

final class RecordDetailViewReactor: Reactor {
    
    // MARK: - Action is an user interaction
    enum Action {
        case tapConfirm
        case tapSave
        case updateMemo(String?)
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setDismiss(Bool)
        case setMemo(String?)
        case setSaveButtonEnabled(Bool)
        case updateOriginalMemo(String?)
    }
    
    // MARK: - State is a current view state
    struct State {
        let record: WorkoutRecord
        var memo: String?
        var originalMemo: String?
        var shouldDismiss: Bool
        var isSaveButtonEnabled: Bool
    }

    // MARK: - Properties
    let initialState: State

    // MARK: - Init
    init(record: WorkoutRecord) {
        self.initialState = State(
            record: record,
            memo: record.comment,
            originalMemo: record.comment,
            shouldDismiss: false,
            isSaveButtonEnabled: false
        )
    }
    
    // MARK: - Mutate(Action -> Mutation)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapConfirm:
            return .just(.setDismiss(true))

        case .tapSave:
            guard let memo = currentState.memo?.trimmingCharacters(in: .whitespacesAndNewlines),
                  memo != "메모를 입력해주세요.",
                  memo != currentState.originalMemo?.trimmingCharacters(in: .whitespacesAndNewlines)
            else {
                print("변경된 값 없음")
                return .empty()
            }

            print("변경된 메모 저장: \(memo)")
            return Observable.from([
                .updateOriginalMemo(memo),
                .setSaveButtonEnabled(false)
            ])

        case let .updateMemo(text):
            let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let current = (trimmed == "메모를 입력해주세요.") ? nil : trimmed
            let original = currentState.record.comment?.trimmingCharacters(in: .whitespacesAndNewlines)
            let isChanged = current != original && !(current?.isEmpty ?? true)

            return Observable.from([
                .setMemo(text),
                .setSaveButtonEnabled(isChanged)
            ])
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
        case let .setSaveButtonEnabled(isEnabled):
            newState.isSaveButtonEnabled = isEnabled
        case let .updateOriginalMemo(newMemo):
            newState.originalMemo = newMemo
        }
        return newState
    }
}
