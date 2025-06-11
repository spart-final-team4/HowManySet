//
//  MyPageViewModel.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import Foundation
import RxSwift
import ReactorKit

/// 마이페이지 화면의 Reactor (ViewModel 역할)
/// - 사용자 액션을 받아 상태 변화를 처리하고 뷰에 반영할 상태를 관리함
final class MyPageViewReactor: Reactor {
    
    private let fetchUserSettingUseCase: FetchUserSettingUseCase
    private let saveUserSettingUseCase: SaveUserSettingUseCase
    
    /// 사용자 액션 (뷰에서 발생하는 이벤트)
    enum Action {
        /// 셀 탭 이벤트, 탭된 셀 타입을 전달
        case cellTapped(MyPageCellType)
    }
    
    /// 상태 변화를 나타내는 Mutation (내부 상태 조작용)
    enum Mutation {
        /// 특정 셀 타입에 대한 화면 전환 지시
        case presentTo(MyPageCellType)
    }
    
    /// 현재 뷰 상태를 담는 구조체
    struct State {
        /// 현재 화면 전환 대상 셀 타입 (없으면 nil)
        var presentTarget: MyPageCellType?
    }
    
    /// 초기 상태
    let initialState: State
    
    /// 생성자
    /// - Parameters:
    ///   - fetchUserSettingUseCase: 사용자 설정 조회용 유스케이스
    ///   - saveUserSettingUseCase: 사용자 설정 저장용 유스케이스
    init(fetchUserSettingUseCase: FetchUserSettingUseCase, saveUserSettingUseCase: SaveUserSettingUseCase) {
        self.fetchUserSettingUseCase = fetchUserSettingUseCase
        self.saveUserSettingUseCase = saveUserSettingUseCase
        self.initialState = State(presentTarget: nil)
    }
    
    /// Action을 Mutation으로 변환하는 메서드
    /// - Parameter action: 뷰에서 전달된 액션
    /// - Returns: 상태 변화를 위한 Mutation Observable
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cellTapped(let cell):
            return .just(.presentTo(cell))
        }
    }
    
    /// Mutation을 받아 새로운 상태로 변환하는 메서드
    /// - Parameters:
    ///   - state: 현재 상태
    ///   - mutation: 수행할 상태 변화
    /// - Returns: 변경된 새 상태
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .presentTo(let myPageCellType):
            newState.presentTarget = myPageCellType
        }
        return newState
    }
}
