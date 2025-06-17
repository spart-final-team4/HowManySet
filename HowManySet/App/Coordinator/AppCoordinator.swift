//
//  AppCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit

/// 앱의 전체 흐름을 관리하는 Coordinator
/// - 로그인 여부, 온보딩 여부를 체크하고 적절한 흐름으로 분기
final class AppCoordinator: Coordinator {
    
    /// 앱의 최상위 UIWindow
    var window: UIWindow
    
    /// 현재 자식 Coordinator들을 보관
    private var childCoordinators: [Coordinator] = []
    
    /// 의존성 주입 컨테이너
    private let container: DIContainer
    
    /// 생성자 - 의존성 주입 및 윈도우 연결
    init(window: UIWindow, container: DIContainer) {
        self.window = window
        self.container = container
    }
    
    /// 앱 시작 시 호출됨 - 로그인/온보딩 상태에 따라 적절한 플로우를 보여줌
    func start() {
        let isLoggedIn = checkLoginStatus()
        let hasCompletedOnboarding = checkOnboardingStatus()
        
        if !isLoggedIn {
            showTabBarFlow()
        } else if !hasCompletedOnboarding {
            showTabBarFlow()
        } else {
            showTabBarFlow()
        }
    }
    
    /// 상태 체크 함수 분리
    private func checkLoginStatus() -> Bool {
        // TODO: 실제 로그인 상태(Firebase 등) 연동
        return false
    }
    
    private func checkOnboardingStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    /// 온보딩 흐름 시작
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
    
    /// 로그인/회원가입 흐름 시작
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(navigationController: UINavigationController(), container: container)
        childCoordinators.append(authCoordinator)
        
        authCoordinator.finishFlow = { [weak self, weak authCoordinator] in
            guard let self, let authCoordinator else { return }
            self.childDidFinish(authCoordinator)
            
            let hasCompletedOnboarding = self.checkOnboardingStatus()
            if hasCompletedOnboarding {
                self.showTabBarFlow()
            } else {
                self.showOnboardingFlow()
            }
        }
        
        authCoordinator.start()
        window.rootViewController = authCoordinator.navigationController
        window.makeKeyAndVisible()
    }
    
    /// 메인 탭바 흐름 시작
    private func showTabBarFlow() {
        let tabBarCoordinator = TabBarCoordinator(tabBarController: UITabBarController(), container: container)
        
        tabBarCoordinator.finishFlow = { [weak self, weak tabBarCoordinator] in
            guard let self, let tabBarCoordinator else { return }
            self.childDidFinish(tabBarCoordinator)
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
