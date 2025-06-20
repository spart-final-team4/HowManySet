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
    }

    struct State {
        var user: User?
        var error: Error?
    }

    let initialState = State()
    private let useCase: AuthUseCaseProtocol
    private let coordinator: AuthCoordinatorProtocol

    init(useCase: AuthUseCaseProtocol, coordinator: AuthCoordinatorProtocol) {
        self.useCase = useCase
        self.coordinator = coordinator
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoLogin:
            return useCase.loginWithKakao()
                .map(Mutation.loginSuccess)
                .catch { .just(.loginFailed($0)) }

        case .tapGoogleLogin:
            return useCase.loginWithGoogle()
                .map(Mutation.loginSuccess)
                .catch { .just(.loginFailed($0)) }

        case .tapAppleLogin(let token, let nonce):
            return useCase.loginWithApple(token: token, nonce: nonce)
                .map(Mutation.loginSuccess)
                .catch { .just(.loginFailed($0)) }

        case .tapAnonymousLogin:
            return useCase.loginAnonymously()
                .map(Mutation.loginSuccess)
                .catch { .just(.loginFailed($0)) }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
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
