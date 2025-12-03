//
//  MembershipViewReactor.swift
//  HowManySet
//
//  Created by MJ on 12/2/25.
//

import Foundation
import ReactorKit
import RxSwift

final class MembershipViewReactor: Reactor {
    
    private let fetchRecordUseCase: FetchRecordUseCaseProtocol
    private let saveRecordUseCase: SaveRecordUseCaseProtocol
    private let deleteRecordUseCase: DeleteRecordUseCaseProtocol
    private let fetchRoutineUseCase: FetchRoutineUseCaseProtocol
    private let saveRoutineUseCase: SaveRoutineUseCaseProtocol
    private let deleteRoutineUseCase: DeleteRoutineUseCaseProtocol
    private let authUseCase: AuthUseCaseProtocol
    
    let initialState: State
    
    enum Action {
        case dismiss
    }
    
    enum Mutation {
        case dismissView(Bool)
    }
    
    struct State {
        var dismiss: Bool = false
    }
    
    init(fetchRecordUseCase: FetchRecordUseCaseProtocol,
         deleteRecordUseCase: DeleteRecordUseCaseProtocol,
         saveRecordUseCase: SaveRecordUseCaseProtocol,
         fetchRoutineUseCase: FetchRoutineUseCaseProtocol,
         deleteRoutineUseCase: DeleteRoutineUseCaseProtocol,
         saveRoutineUseCase: SaveRoutineUseCaseProtocol,
         authUseCase: AuthUseCaseProtocol
    ) {
        self.fetchRecordUseCase = fetchRecordUseCase
        self.deleteRecordUseCase = deleteRecordUseCase
        self.saveRecordUseCase = saveRecordUseCase
        self.fetchRoutineUseCase = fetchRoutineUseCase
        self.deleteRoutineUseCase = deleteRoutineUseCase
        self.saveRoutineUseCase = saveRoutineUseCase
        self.authUseCase = authUseCase
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .dismiss:
                .just(.dismissView(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .dismissView(let value):
            newState.dismiss = value
        }
        
        return newState
    }
    
}
