//
//  AppCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import FirebaseAuth
import RxSwift

/// 앱의 전체 흐름을 관리하는 Coordinator
/// - 로그인 여부, 온보딩 여부를 체크하고 적절한 흐름으로 분기
final class AppCoordinator: Coordinator {
    
    /// 앱의 최상위 UIWindow
    var window: UIWindow
    
    /// 현재 자식 Coordinator들을 보관
    private var childCoordinators: [Coordinator] = []
    
    /// 의존성 주입 컨테이너
    private let container: DIContainer
    
    /// RxSwift DisposeBag
    private let disposeBag = DisposeBag()
    
    /// 생성자 - 의존성 주입 및 윈도우 연결
    init(window: UIWindow, container: DIContainer) {
        self.window = window
        self.container = container
    }
    
    /// 앱 시작 시 호출됨 - 사용자별 상태 확인하여 적절한 플로우로 분기
    func start() {
        let isLoggedIn = checkLoginStatus()
        
        if !isLoggedIn {
            showAuthFlow()
        } else {
            // 로그인된 사용자의 상태를 UseCase를 통해 확인
            checkUserStatus()
        }
    }
    
    /// 로그인 상태 확인
    private func checkLoginStatus() -> Bool {
        let isLoggedIn = Auth.auth().currentUser != nil
        print("✅ 로그인 상태: \(isLoggedIn)")
        return isLoggedIn
    }
    
    /// 사용자 상태 확인 (UseCase를 통해)
    private func checkUserStatus() {
        guard let currentUser = Auth.auth().currentUser else {
            showAuthFlow()
            return
        }

        let firebaseAuthService = FirebaseAuthService()
        let authRepository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let authUseCase = AuthUseCase(repository: authRepository)
        
        authUseCase.getUserStatus(uid: currentUser.uid)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] userStatus in
                    switch userStatus {
                    case .needsOnboarding:
                        self?.showOnboardingFlow()
                    case .complete:
                        self?.showTabBarFlow()
                    }
                },
                onError: { [weak self] error in
                    print("사용자 상태 조회 실패: \(error)")
                    // 에러 시 온보딩부터 시작
                    self?.showOnboardingFlow()
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// 로그인/회원가입 흐름 시작
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(navigationController: UINavigationController(), container: container)
        childCoordinators.append(authCoordinator)
        
        authCoordinator.finishFlow = { [weak self, weak authCoordinator] in
            guard let self, let authCoordinator else { return }
            self.childDidFinish(authCoordinator)
            
            // 로그인 완료 후 사용자 상태 확인
            self.checkUserStatus()
        }
        
        authCoordinator.start()
        window.rootViewController = authCoordinator.navigationController
        window.makeKeyAndVisible()
    }
    
    /// 온보딩 흐름 시작 (닉네임 입력 + 온보딩)
    private func showOnboardingFlow() {
        let onboardingCoordinator = OnBoardingCoordinator(navigationController: UINavigationController(), container: container)
        childCoordinators.append(onboardingCoordinator)
        
        onboardingCoordinator.finishFlow = { [weak self, weak onboardingCoordinator] in
            guard let self, let onboardingCoordinator else { return }
            self.showTabBarFlow()
            self.childDidFinish(onboardingCoordinator)
        }
        
        onboardingCoordinator.start()
        window.rootViewController = onboardingCoordinator.navigationController
        window.makeKeyAndVisible()
    }
    
    /// 메인 탭바 흐름 시작
    private func showTabBarFlow() {
        let tabBarCoordinator = TabBarCoordinator(tabBarController: UITabBarController(), container: container)
        
        tabBarCoordinator.finishFlow = { [weak self, weak tabBarCoordinator] in
            guard let self, let tabBarCoordinator else { return }
            self.childDidFinish(tabBarCoordinator)
            // 로그아웃/계정삭제 후 인증 화면으로 이동
            self.showAuthFlow()
        }
        
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
    
    /// 자식 Coordinator가 완료되었을 때 배열에서 제거
    /// - 메모리 누수 방지 및 흐름 정리를 위함
    private func childDidFinish(_ child: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if ObjectIdentifier(coordinator) == ObjectIdentifier(child) {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
