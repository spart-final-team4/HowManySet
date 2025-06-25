import Foundation
import RxSwift
import ReactorKit

final class CalendarViewReactor: Reactor {

    private let deleteRecordUseCase: DeleteRecordUseCase
    private let fetchRecordUseCase: FetchRecordUseCase
    private let fsDeleteRecordUseCase: FSDeleteRecordUseCase
    private let fsFetchRecordUseCase: FSFetchRecordUseCase

    // MARK: - Action is an user interaction
    enum Action {
        case viewWillAppear
        case selectDate(Date)
        case deleteItem(IndexPath)
        case clearSelection
    }

    // MARK: - Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setAllRecords([WorkoutRecord])
        case setSelectedDate(Date)
        case setSelectedRecords([WorkoutRecord])
        case deleteRecordAt(IndexPath)
        case clearSelectedDate
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
        fetchRecordUseCase: FetchRecordUseCase,
        fsDeleteRecordUseCase: FSDeleteRecordUseCase,
        fsFetchRecordUseCase: FSFetchRecordUseCase
    ) {
        self.deleteRecordUseCase = deleteRecordUseCase
        self.fetchRecordUseCase = fetchRecordUseCase
        self.fsDeleteRecordUseCase = fsDeleteRecordUseCase
        self.fsFetchRecordUseCase = fsFetchRecordUseCase
        self.initialState = State()
    }

    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchRecordUseCase.execute()
                .map { Mutation.setAllRecords($0) }
                .asObservable()

//            let realmRecords = fetchRecordUseCase.execute()
//                .map { Mutation.setAllRecords($0) }
//                .asObservable()
//
//            let fsRecords = fsFetchRecordUseCase.execute(uid: uid ?? "")
//                .map { Mutation.setAllRecords($0) }
//                .asObservable()
//
//            return Observable.merge([realmRecords, fsRecords])

        case let .selectDate(date):
            let fetchRecords = fetchRecordUseCase.execute()
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
            deleteRecordUseCase.execute(item: recordToDelete)
//
//            if let uid = uid {
//                fsDeleteRecordUseCase.execute(uid: uid, item: recordToDelete)
//            }

            return .just(.deleteRecordAt(indexPath))

        case .clearSelection:
            return .just(.clearSelectedDate)
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
        case .clearSelectedDate:
            newState.selectedDate = Date()
            newState.selectedRecords = []
        }

        return newState
    }
}
