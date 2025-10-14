import Foundation
import ReactorKit
import RxSwift

final class NicknameInputViewReactor: Reactor {

    enum Action {
        case inputNickname(String)
        case completeNicknameSetting
    }

    enum Mutation {
        case setNickname(String)
        case setNicknameComplete
        case setError(Error?)
        case setNicknameValid(Bool)
    }

    struct State {
        var nickname: String?
        var isNicknameComplete = false
        var isNicknameValid = false
        var error: Error?
    }

    let initialState: State
    private let authUseCase: AuthUseCaseProtocol
    private weak var coordinator: NicknameInputCoordinatorProtocol?

    init(authUseCase: AuthUseCaseProtocol, coordinator: NicknameInputCoordinatorProtocol, initialState: State = State()) {
        self.authUseCase = authUseCase
        self.coordinator = coordinator
        self.initialState = initialState
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputNickname(let nickname):
            return authUseCase.checkNicknameValid(nickname)
                .flatMap { isValid in
                    Observable.concat([
                        Observable.just(.setNickname(nickname)),
                        Observable.just(.setError(nil)),
                        Observable.just(.setNicknameValid(isValid))
                    ])
                }
        case .completeNicknameSetting:
            guard let nickname = currentState.nickname else {
                return Observable.just(.setError(NSError(domain: "NicknameRequired", code: -1)))
            }
            return authUseCase.completeNicknameSetting(nickname: nickname)
                .map { _ in .setNicknameComplete }
                .catch { error in Observable.just(.setError(error)) }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickname(let nickname):
            newState.nickname = nickname
        case .setNicknameComplete:
            newState.isNicknameComplete = true
            DispatchQueue.main.async { [weak self] in
                self?.coordinator?.completeNicknameInput()
            }
        case .setError(let error):
            newState.error = error
        case .setNicknameValid(let isValid):
            newState.isNicknameValid = isValid
        }
        return newState
    }
}
