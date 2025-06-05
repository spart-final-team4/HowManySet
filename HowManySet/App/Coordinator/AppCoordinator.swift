//
//  AppCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    var window: UIWindow
    private var childCoordinators: [Coordinator] = []
    private let container: DIContainer
    
    init(window: UIWindow, container: DIContainer) {
        self.window = window
        self.container = container
    }

    func start() {
        // 앱 시작 시 로그인 여부, 온보딩 완료 여부 등을 확인
        // 현재 테스트 위해 true값으로 고정 - 추후 수정 필요
        let isLoggedIn = true // ... (Firebase Auth, UserDefaults 등 확인)
        let hasCompletedOnboarding = true // ... (UserDefaults 등 확인)

        if !hasCompletedOnboarding {
            showOnboardingFlow()
        } else if !isLoggedIn {
            showAuthFlow()
        } else {
            showTabBarFlow()
        }
    }
    
    private func showOnboardingFlow() {
        let onBoardingCoordinator = OnBoardingCoordinator(navigationController: UINavigationController(), container: container)
        onBoardingCoordinator.finishFlow = { [weak self, weak onBoardingCoordinator] in
            // 온보딩 완료 후 처리 (예: 온보딩 완료 상태 저장, 로그인 흐름으로 전환)
            guard let onBoardingCoordinator, let self else { return }
            self.childDidFinish(onBoardingCoordinator)
            onBoardingCoordinator.completeOnBoarding()
            self.showAuthFlow()
        }
        onBoardingCoordinator.start()
        
        window.rootViewController = onBoardingCoordinator.navigationController
        window.makeKeyAndVisible()
    }

    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(navigationController: UINavigationController(), container: container)
        authCoordinator.finishFlow = { [weak self, weak authCoordinator] in
            // 로그인/회원가입 완료 후 처리 (예: 로그인 상태 저장, 메인 흐름으로 전환)
            guard let authCoordinator, let self else { return }
            self.childDidFinish(authCoordinator)
            self.showTabBarFlow()
        }
        authCoordinator.start()
        
        window.rootViewController = authCoordinator.navigationController
        window.makeKeyAndVisible()
    }

    private func showTabBarFlow() {
        let tabBarCoordinator = TabBarCoordinator(tabBarController: UITabBarController(), container: container)
    
        tabBarCoordinator.start()
        
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
    
    private func childDidFinish(_ child: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if ObjectIdentifier(coordinator) == ObjectIdentifier(child) {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
