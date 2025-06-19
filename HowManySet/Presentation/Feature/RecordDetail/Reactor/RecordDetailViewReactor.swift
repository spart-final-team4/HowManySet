import Foundation
import RxSwift
import ReactorKit

final class RecordDetailViewReactor: Reactor {
    // MARK: - UseCase
    private let saveRecordUseCase: SaveRecordUseCase
    private let fetchRecordUseCase: FetchRecordUseCase

    // MARK: - Action is an user interaction
    enum Action {
        case tapConfirm
        case tapSave
        case updateMemo(String?)
        case refreshRecord
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setDismiss(Bool)
        case setMemo(String?)
        case setSaveButtonEnabled(Bool)
        case updateOriginalMemo(String?)
        case setFetchedRecord(WorkoutRecord)
    }
    
    // MARK: - State is a current view state
    struct State {
        var record: WorkoutRecord
        var memo: String?
        var originalMemo: String?
        var shouldDismiss: Bool
        var isSaveButtonEnabled: Bool
    }

    // MARK: - Properties
    let initialState: State

    // MARK: - Init
    init(saveRecordUseCase: SaveRecordUseCase,
         fetchRecordUseCase: FetchRecordUseCase,
         record: WorkoutRecord
    ) {
        self.saveRecordUseCase = saveRecordUseCase
        self.fetchRecordUseCase = fetchRecordUseCase
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
                print("변경된 값 없음") // ✅ print
                return .empty()
            }

            let updatedRecord = currentState.record.withUpdatedComment(memo)

            // 실제 저장 UseCase 호출
            saveRecordUseCase.execute(uid: "", item: updatedRecord)

            print("변경된 메모 저장: \(memo)") // ✅ print
            return Observable.from([
                .updateOriginalMemo(memo),
                .setSaveButtonEnabled(false)
            ])

        case let .updateMemo(text):
            let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let current = (trimmed == "메모를 입력해주세요.") ? nil : trimmed
            let original = currentState.record.comment?.trimmingCharacters(in: .whitespacesAndNewlines)
            let isChanged = (current != original) && !(current?.isEmpty ?? true)

            return Observable.from([
                .setMemo(text),
                .setSaveButtonEnabled(isChanged)
            ])

        case .refreshRecord:
            // 실제 fetch 흐름
            return fetchRecordUseCase.execute(uid: "")
                .map { Mutation.setFetchedRecord($0.first ?? self.currentState.record) }
                .asObservable()
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
        case let .setFetchedRecord(record): // fetch 처리
            newState.record = record
            newState.memo = record.comment
            newState.originalMemo = record.comment
        }

        return newState
    }
}
