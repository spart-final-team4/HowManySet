//
//  AuthViewReactor.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

import Foundation
import ReactorKit
import RxSwift

final class AuthViewReactor: Reactor {

    enum Action {
        case tapKakaoLogin
        case tapGoogleLogin
        case tapAppleLogin(idToken: String, nonce: String)
        case tapAnonymousLogin
    }

    enum Mutation {
        case loginSuccess(User)
        case loginFailed(Error)
        case setLoading(Bool)
    }

    struct State {
        var user: User?
        var error: Error?
        var isLoading: Bool = false
    }

    let initialState = State()
    private let useCase: AuthUseCaseProtocol
    private let coordinator: AuthCoordinatorProtocol

    init(useCase: AuthUseCaseProtocol, coordinator: AuthCoordinatorProtocol) {
        self.useCase = useCase
        self.coordinator = coordinator
    }

    func mutate(action: Action) -> Observable<Mutation> {
        let loginObservable: Observable<User>

        switch action {
        case .tapKakaoLogin:
            loginObservable = useCase.loginWithKakao()

        case .tapGoogleLogin:
            loginObservable = useCase.loginWithGoogle()

        case .tapAppleLogin(let token, let nonce):
            loginObservable = useCase.loginWithApple(token: token, nonce: nonce)

        case .tapAnonymousLogin:
            loginObservable = useCase.loginAnonymously()
        }

        return Observable.concat([
            .just(.setLoading(true)), // ✅ 로딩 시작
            loginObservable
                .map(Mutation.loginSuccess)
                .catch { .just(.loginFailed($0)) },
            .just(.setLoading(false)) // ✅ 로딩 종료
        ])
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .loginSuccess(let user):
            newState.user = user
            newState.error = nil
            coordinator.completeAuth()

        case .loginFailed(let error):
            newState.error = error
        }
        return newState
    }
}
