//
//  HomePagingCardViewReactor.swift
//  HowManySet
//
//  Created by 정근호 on 6/11/25.
//

import Foundation
import RxSwift
import ReactorKit
import RxRelay

/// 사용자에게 보여지는 운동 종목 카드 뷰의 정보를 담은 구조체
struct WorkoutCardState {
    
    // UI에 직접 표시될 값들 (Reactor에서 미리 계산하여 제공)
    var currentExerciseName: String
    var currentWeight: Double
    var currentUnit: String
    var currentReps: Int
    /// 현재 진행 중인 세트 인덱스
    var setIndex: Int
    
    /// 전체 운동 개수
    var totalExerciseCount: Int
    /// 현재 운동의 전체 세트 개수
    var totalSetCount: Int
    /// UI용 "1 / N"에서 1
    var currentExerciseNumber: Int
    /// UI용 "1 / N"에서 1
    var currentSetNumber: Int
    /// 세트 프로그레스바
    var setProgressAmount: Int
    
    /// 현재 운동 종목의 메모
    var commentInExercise: String?
}

//// 세트 관련 속성만 변경 감지
//extension WorkoutCardState: Equatable {
//    static func == (lhs: WorkoutCardState, rhs: WorkoutCardState) -> Bool {
//        return lhs.currentSetNumber == rhs.currentSetNumber &&
//               lhs.setProgressAmount == rhs.setProgressAmount
//    }
//}


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
    let index: Int
    
    // HomeViewReactor로 전달할 액션 스트림
    let homeViewAction = PublishRelay<HomeViewReactor.Action>()
    
    init(initialCardState: WorkoutCardState, index: Int) {
        self.initialState = State(cardState: initialCardState)
        self.index = index
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            
        case .updateCardState(let newCardState):
            print("updateCardState: \(newCardState)")
            return .just(.setWorkoutCardState(newCardState))
        }
    }

    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {
            
        case .setWorkoutCardState(let cardState):
            print("setWorkoutCardState: \(cardState)")
            state.cardState = cardState
        }
        
        return state
    }
}

