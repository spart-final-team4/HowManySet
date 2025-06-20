//
//  OnBoardingCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol OnBoardingCoordinatorProtocol: Coordinator {
    func completeOnBoarding()
}

/// 온보딩 흐름 담당 coordinator
/// 온보딩 뷰 진입 및 완료 시 finishFlow 호출
final class OnBoardingCoordinator: OnBoardingCoordinatorProtocol {
    
    /// 온보딩 완료 시 호출될 클로저
    var finishFlow: (() -> Void)?
    
    /// 온보딩 흐름 navigation controller
    let navigationController: UINavigationController
    
    /// DI 컨테이너
    private let container: DIContainer

    /// coordinator 생성자
    /// - Parameters:
    ///   - navigationController: 온보딩 흐름용 navigation
    ///   - container: DI 컨테이너
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    /// 온보딩 흐름 시작
    func start() {
        let onboardingVC = container.makeOnBoardingViewController(coordinator: self)
        navigationController.pushViewController(onboardingVC, animated: true)
    }

    /// 온보딩 완료 시 호출
    func completeOnBoarding() {
        // TODO: 필요한 비즈니스 로직들 추가
        // UserDefaults에 온보딩 완료 상태 저장
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        print(#function)
        finishFlow?()
    }
}
