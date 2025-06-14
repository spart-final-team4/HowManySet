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
        let isLoggedIn = false // TODO: 로그인 상태 확인 로직 추가 필요
        let hasCompletedOnboarding = true // TODO: 온보딩 완료 여부 확인 로직 추가 필요

        if !hasCompletedOnboarding {
            showOnboardingFlow()
        } else if !isLoggedIn {
            showAuthFlow()
        } else {
            showTabBarFlow()
        }
    }
    
    /// 온보딩 흐름 시작
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

    /// 로그인/회원가입 흐름 시작
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

    /// 메인 탭바 흐름 시작
    private func showTabBarFlow() {
        let tabBarCoordinator = TabBarCoordinator(tabBarController: UITabBarController(), container: container)
    
        tabBarCoordinator.start()
        
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
