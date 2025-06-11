//
//  HomePagingCardViewReactor.swift
//  HowManySet
//
//  Created by 정근호 on 6/11/25.
//

import Foundation
import RxSwift
import ReactorKit

final class HomePagingCardViewReactor: Reactor {
    
    // Action is an user interaction
    enum Action {
        
        /// HomeViewReactor에서 카드 상태 업데이트 시 주입
        case updateCardState(WorkoutCardState)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setWorkoutCardState(WorkoutCardState)
    }
    
    // State is a current view state
    struct State {
        /// 카드 뷰에 표시될 운동 정보 (세트 번호, 무게, 횟수 등)
        var cardState: WorkoutCardState

    }
    
    let initialState: State
    
    init(initialCardState: WorkoutCardState) {
       self.initialState = State(cardState: initialCardState)
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateCardState(let newCardState):
            return .just(.setWorkoutCardState(newCardState))
        }
    }

    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setWorkoutCardState(let cardState):
            newState.cardState = cardState
        }
        return newState
    }
}

