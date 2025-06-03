//
//  OnBoardingCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol OnBoardingCoordinatorProtocol: Coordinator {
    
}

final class OnBoardingCoordinator: OnBoardingCoordinatorProtocol {
    
    /// 온보딩 완료 시 호출될 클로저
    var finishFlow: (() -> Void)?
    let navigationController: UINavigationController
    private let container: DIContainer
    
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let onboardingVC = container.makeOnBoardingViewController(coordinator: self)
        
        navigationController.pushViewController(onboardingVC, animated: true)
    }
    
    /// 온보딩 종료 시 호출
    func completeOnBoarding() {
        
        // 필요한 비즈니스 로직들 추가
        // UserDefaults에 온보딩 완료 상태 저장
//        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        print(#function)
        
        finishFlow?()
    }

}
