import Foundation
import RxSwift
import ReactorKit

final class RoutineNameReactor: Reactor {

    private let saveRoutineUseCase: SaveRoutineUseCase

    // MARK: - Action is an user interaction
    enum Action {
        case setRoutineName(String)
        case saveRoutine
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
    init(saveRoutineUseCase: SaveRoutineUseCase) {
        self.saveRoutineUseCase = saveRoutineUseCase
        self.initialState = State()
    }

    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setRoutineName(name):
            return .just(.setRoutineName(name))
        case .saveRoutine:
            let routine = WorkoutRoutine(name: currentState.routineName, workouts: [])
            saveRoutineUseCase.execute(uid: "test-user", item: routine)
            print("루틴명 저장 성공: \(routine.name)")
            return .empty()
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
