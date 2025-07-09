import Foundation
import RxSwift
import ReactorKit

final class CalendarViewReactor: Reactor {

    private let deleteRecordUseCase: DeleteRecordUseCase
    private let fetchRecordUseCase: FetchRecordUseCase

    // MARK: - Action is an user interaction
    enum Action {
        case viewWillAppear
        case selectDate(Date)
        case deleteItem(IndexPath)
    }

    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setAllRecords([WorkoutRecord])
        case setSelectedDate(Date)
        case setSelectedRecords([WorkoutRecord])
        case deleteRecordAt(IndexPath)
    }

    // MARK: - State is a current view state
    struct State {
        var selectedDate: Date = Date()
        var selectedRecords: [WorkoutRecord] = []
        var allRecords: [WorkoutRecord] = []
    }

    let initialState: State

    private let uid = FirebaseAuthService().fetchCurrentUser()?.uid

    // MARK: - Init
    init(
        deleteRecordUseCase: DeleteRecordUseCase,
        fetchRecordUseCase: FetchRecordUseCase
    ) {
        self.deleteRecordUseCase = deleteRecordUseCase
        self.fetchRecordUseCase = fetchRecordUseCase
        self.initialState = State()
    }

    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchRecordUseCase.execute(uid: uid)
                .map { Mutation.setAllRecords($0) }
                .asObservable()

        case let .selectDate(date):
            let fetchRecords = fetchRecordUseCase.execute(uid: uid)
                .map { allRecords in
                    let filteredRecords = allRecords.filter {
                        Calendar.current.isDate($0.date, inSameDayAs: date)
                    }
                    return Mutation.setSelectedRecords(filteredRecords)
                }
                .asObservable()

            return Observable.concat([
                .just(.setSelectedDate(date)),
                fetchRecords
            ])
//
//            let realmFetchRecords = fetchRecordUseCase.execute()
//
//            let fsFetchRecords = fsFetchRecordUseCase.execute(uid: uid ?? "")
//
//            let combinedFetch = Observable.zip(realmFetchRecords.asObservable(), fsFetchRecords.asObservable())
//                .map { realmFetchRecords, fsFetchRecords in
//                    let allRecords = realmFetchRecords + fsFetchRecords
//                    let filteredRecords = allRecords.filter {
//                        Calendar.current.isDate($0.date, inSameDayAs: date)
//                    }
//                    return Mutation.setSelectedRecords(filteredRecords)
//                }
//
//            return Observable.concat([
//                .just(.setSelectedDate(date)),
//                combinedFetch
//            ])

        case let .deleteItem(indexPath):
            let recordToDelete = currentState.selectedRecords[indexPath.row]
            deleteRecordUseCase.execute(uid: uid, item: recordToDelete)

            return .just(.deleteRecordAt(indexPath))
        }
    }

    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setAllRecords(records):
            newState.allRecords = records
        case let .setSelectedDate(date):
            newState.selectedDate = date
        case let .setSelectedRecords(records):
            newState.selectedRecords = records
        case let .deleteRecordAt(indexPath):
            var updatedRecords = state.selectedRecords
            updatedRecords.remove(at: indexPath.row)
            newState.selectedRecords = updatedRecords
        }

        return newState
    }
}
