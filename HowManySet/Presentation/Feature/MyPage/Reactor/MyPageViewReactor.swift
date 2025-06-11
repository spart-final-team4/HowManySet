//
//  MyPageViewModel.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import Foundation
import RxSwift
import ReactorKit

final class MyPageViewReactor: Reactor {
    
    private let fetchUserSettingUseCase: FetchUserSettingUseCase
    private let saveUserSettingUseCase: SaveUserSettingUseCase
    
    // Action is an user interaction
    enum Action {
        case cellTapped(MyPageCellType)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case presentTo(MyPageCellType)
    }
    
    // State is a current view state
    struct State {
        var presentTarget: MyPageCellType?
    }
    
    let initialState: State
    
    init(fetchUserSettingUseCase: FetchUserSettingUseCase, saveUserSettingUseCase: SaveUserSettingUseCase) {
        self.fetchUserSettingUseCase = fetchUserSettingUseCase
        self.saveUserSettingUseCase = saveUserSettingUseCase
        self.initialState = State(presentTarget: nil)
        
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cellTapped(let cell):
            return .just(.presentTo(cell))
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .presentTo(let myPageCellType):
            newState.presentTarget = myPageCellType
        }
        return newState
    }
}
