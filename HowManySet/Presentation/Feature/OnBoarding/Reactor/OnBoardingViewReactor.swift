//
//  OnBoardingViewReactor.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

import Foundation
import RxSwift
import ReactorKit

/**
 온보딩 및 닉네임 입력의 상태와 비즈니스 로직을 관리하는 Reactor.
 
 - 역할: 사용자 입력(닉네임, 페이지 이동, 온보딩 완료 등)을 Action으로 받아 상태를 Mutation으로 변경하고, State로 반영합니다.
 - 특징: ReactorKit의 핵심 컴포넌트로, UI 로직과 분리된 비즈니스 로직을 담당합니다.
 - 의존성: 닉네임 설정 및 온보딩 완료 처리를 위한 AuthUseCaseProtocol 주입.
 */
final class OnBoardingViewReactor: Reactor {
    // MARK: - Action
    /// 사용자 상호작용을 정의한 액션 타입
    enum Action {
        case inputNickname(String)      // 닉네임 입력 액션
        case moveToNextPage             // 다음 페이지 이동 액션
        case skipOnboarding             // 온보딩 건너뛰기 액션
        case completeNicknameSetting    // 닉네임 설정 완료 액션
    }
    
    // MARK: - Mutation
    /// 상태 변경을 위한 변이 타입
    enum Mutation {
        case setNickname(String)        // 닉네임 상태 업데이트
        case setPageIndex(Int)          // 페이지 인덱스 업데이트
        case setOnboardingComplete      // 온보딩 완료 상태 업데이트
        case setNicknameComplete        // 닉네임 설정 완료 상태 업데이트
        case setError(Error?)           // 에러 상태 업데이트
        case setNicknameValid(Bool)     // 닉네임 유효성 결과 업데이트
    }
    
    // MARK: - State
    /// 현재 뷰의 상태를 나타내는 타입
    struct State {
        var nickname: String?           // 현재 입력된 닉네임
        var currentPageIndex: Int = 0   // 현재 페이지 인덱스 (0부터 시작)
        var isOnboardingComplete = false// 온보딩 완료 여부
        var isNicknameComplete = false  // 닉네임 설정 완료 여부
        var error: Error?               // 발생한 에러
        var isNicknameValid: Bool = false // 닉네임 유효성 결과
    }
    
    // MARK: - Properties
    let initialState: State
    private let authUseCase: AuthUseCaseProtocol
    private weak var coordinator: OnBoardingCoordinatorProtocol?
    
    // MARK: - Initialization
    /**
     Reactor 초기화
     
     - Parameters:
       - authUseCase: 닉네임 설정 및 온보딩 완료 처리를 위한 UseCase
       - coordinator: 온보딩 플로우 완료 시 호출할 Coordinator
       - initialState: 초기 상태 값 (기본값: State())
     */
    init(
        authUseCase: AuthUseCaseProtocol,
        coordinator: OnBoardingCoordinatorProtocol,
        initialState: State = State()
    ) {
        self.authUseCase = authUseCase
        self.coordinator = coordinator
        self.initialState = initialState
    }
    
    // MARK: - Mutation Handler
    /**
     액션을 변이로 변환하는 메서드
     
     - Parameter action: 사용자 액션
     - Returns: 해당 액션에 대응하는 Mutation Observable
     */
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputNickname(let nickname):
            // AuthUseCase의 checkNicknameValid를 활용
            return authUseCase.checkNicknameValid(nickname)
                .flatMap { isValid -> Observable<Mutation> in
                    Observable.concat([
                        Observable.just(.setNickname(nickname)),
                        Observable.just(.setError(nil)),
                        Observable.just(.setNicknameValid(isValid))
                    ])
                }
            
        case .moveToNextPage:
            let nextPage = currentState.currentPageIndex + 1
            if nextPage < OnBoardingViewReactor.onboardingPages.count {
                return Observable.just(.setPageIndex(nextPage))
            } else {
                // 마지막 페이지에서는 페이지 인덱스를 변경하지 않고 바로 완료 처리
                return authUseCase.completeOnboarding()
                    .map { _ in .setOnboardingComplete }
                    .catch { error in Observable.just(.setError(error)) }
            }
            
        case .skipOnboarding:
            // AuthUseCase의 completeOnboarding() 메서드 활용 (uid 내부 처리)
            return authUseCase.completeOnboarding()
                .map { _ in .setOnboardingComplete }
                .catch { error in Observable.just(.setError(error)) }
            
        case .completeNicknameSetting:
            guard let nickname = currentState.nickname else {
                return Observable.just(.setError(NSError(domain: "NicknameRequired", code: -1)))
            }
            // AuthUseCase의 completeNicknameSetting(nickname:) 메서드 활용 (uid 내부 처리)
            return authUseCase.completeNicknameSetting(nickname: nickname)
                .map { _ in .setNicknameComplete }
                .catch { error in Observable.just(.setError(error)) }
        }
    }
    
    // MARK: - State Reducer
    /**
     변이를 현재 상태에 적용하는 메서드
     
     - Parameters:
       - state: 현재 상태
       - mutation: 적용할 변이
     - Returns: 변이가 적용된 새로운 상태
     */
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickname(let nickname):
            newState.nickname = nickname
        case .setPageIndex(let index):
            newState.currentPageIndex = index
        case .setOnboardingComplete:
            newState.isOnboardingComplete = true
            // 즉시 coordinator 호출하여 화면 전환 시작
            coordinator?.completeOnBoarding()
        case .setNicknameComplete:
            newState.isNicknameComplete = true
        case .setError(let error):
            newState.error = error
        case .setNicknameValid(let isValid):
            newState.isNicknameValid = isValid
        }
        return newState
    }
    
    // MARK: - Onboarding Data
    /**
     온보딩 페이지 데이터 구조체
     */
    struct OnboardingPageData {
        let title: String
        let subtitle: String
        let imageName: String
    }
    
    /**
     정적 온보딩 페이지 데이터 배열
     - Note: 각 페이지의 타이틀, 서브타이틀, 이미지명을 포함
     */
    static let onboardingPages: [OnboardingPageData] = [
        .init(title: "운동 이름부터 세트 수까지", subtitle: "내 루틴에 맞게 직접 설정해보세요", imageName: "Onboard_SetRoutine"),
        .init(title: "오늘은 어떤 운동할까?", subtitle: "원하는 루틴만 골라 시작하세요", imageName: "Onboard_RoutineList"),
        .init(title: "운동을 완료하면 세트 완료를 클릭하고,", subtitle: "휴식 시간을 미리 설정해보세요", imageName: "Onboard_BreakTime"),
        .init(title: "운동 중 화면에서 무게, 횟수 클릭 시", subtitle: "세트 수, 무게를 변경할 수 있어요", imageName: "Onboard_WorkOutSetting"),
        .init(title: "휴식 타이머를 확인하고,", subtitle: "물 한 잔으로 리프레시해보세요!", imageName: "Onboard_Water"),
        .init(title: "운동 중엔 앱을 꺼도 OK!", subtitle: "잠금화면에서 운동 완료, 휴식까지 한 번에", imageName: "Onboard_LiveActivity")
    ]
}
