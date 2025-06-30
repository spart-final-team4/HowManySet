import Foundation
import RxSwift
import ReactorKit

final class RecordDetailViewReactor: Reactor {
    // MARK: - UseCase
    private let updateRecordUseCase: UpdateRecordUseCase
    // TODO: FSUpdateRecordUseCase

    // MARK: - Action is an user interaction
    enum Action {
        case tapConfirm
        case tapSave
        case updateMemo(String?)
        case resetDidUpdateMemo
    }
    
    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setDismiss(Bool)
        case setMemo(String?)
        case setSaveButtonEnabled(Bool)
        case updateOriginalMemo(String?)
        case setDidUpdateMemo(Bool)
    }
    
    // MARK: - State is a current view state
    struct State {
        var record: WorkoutRecord
        var memo: String?
        var originalMemo: String?
        var shouldDismiss: Bool
        var isSaveButtonEnabled: Bool
        var didUpdateMemo: Bool
    }

    // MARK: - Properties
    let initialState: State
    private let uid = FirebaseAuthService().fetchCurrentUser()?.uid
    
    // MARK: - Init
    init(updateRecordUseCase: UpdateRecordUseCase,
         record: WorkoutRecord
    ) {
        self.updateRecordUseCase = updateRecordUseCase
        self.initialState = State(
            record: record,
            memo: record.comment,
            originalMemo: record.comment,
            shouldDismiss: false,
            isSaveButtonEnabled: false,
            didUpdateMemo: false
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

            let record = currentState.record
            // 직접 WorkoutRecord를 복사하면서 comment만 변경
            let updatedRecord = WorkoutRecord(
                rmID: record.rmID,
                documentID: record.documentID,
                workoutRoutine: record.workoutRoutine,
                totalTime: record.totalTime,
                workoutTime: record.workoutTime,
                comment: memo,
                date: record.date
            )

            // 업데이트 실행
            updateRecordUseCase.execute(uid: uid, item: updatedRecord)

            print("변경된 메모 저장: \(memo)") // ✅ print
            return Observable.from([
                .updateOriginalMemo(memo),
                .setSaveButtonEnabled(false),
                .setDidUpdateMemo(true)
            ])

        case let .updateMemo(text):
            let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let current = (trimmed == "메모를 입력해주세요.") ? nil : trimmed
            let original = currentState.originalMemo?.trimmingCharacters(in: .whitespacesAndNewlines)
            let isChanged = (current != original) && !(current?.isEmpty ?? true)

            return Observable.from([
                .setMemo(text),
                .setSaveButtonEnabled(isChanged)
            ])

        case .resetDidUpdateMemo:
            return .just(.setDidUpdateMemo(false)) // 상태 초기화
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
        case let .setDidUpdateMemo(value):
            newState.didUpdateMemo = value
        }

        return newState
    }
}
