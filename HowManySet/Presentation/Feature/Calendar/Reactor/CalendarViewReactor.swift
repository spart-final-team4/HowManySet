import Foundation
import RxSwift
import ReactorKit

final class CalendarViewReactor: Reactor {

    private let deleteRecordUseCase: DeleteRecordUseCase
    private let fetchRecordUseCase: FetchRecordUseCase

    // MARK: - Action is an user interaction
    enum Action {
        case selectDate(Date)
        case deleteItem(IndexPath)
    }

    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setSelectedDate(Date)
        case setRecords([WorkoutRecord])
        case deleteRecordAt(IndexPath)
    }

    // MARK: - State is a current view state
    struct State {
        var selectedDate: Date = Date()
        var records: [WorkoutRecord] = []
    }

    let initialState: State

    // MARK: - Init
    init(deleteRecordUseCase: DeleteRecordUseCase, fetchRecordUseCase: FetchRecordUseCase) {
        self.deleteRecordUseCase = deleteRecordUseCase
        self.fetchRecordUseCase = fetchRecordUseCase
        self.initialState = State()
    }

    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .selectDate(date):
            // 실제 fetch 대신 mockData 사용
            let calendar = Calendar.current
            let filteredRecords = WorkoutRecord.mockData.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }

            return Observable.concat([
                Observable.just(.setSelectedDate(date)),
                Observable.just(.setRecords(filteredRecords))
            ])

        case let .deleteItem(indexPath):
            let recordToDelete = currentState.records[indexPath.row]
            deleteRecordUseCase.execute(uid: "", item: recordToDelete)

            return .just(.deleteRecordAt(indexPath))
        }
    }

    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setSelectedDate(date):
            newState.selectedDate = date
        case let .setRecords(records):
            newState.records = records
        case let .deleteRecordAt(indexPath):
            var updatedRecords = state.records
            updatedRecords.remove(at: indexPath.row)
            newState.records = updatedRecords
        }

        return newState
    }
}
