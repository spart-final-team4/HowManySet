//
//  AuthCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol AuthCoordinatorProtocol: Coordinator {
    
}

final class AuthCoordinator: AuthCoordinatorProtocol {
    
    /// 로그인 완료 시 호출될 클로저
    var finishFlow: (() -> Void)?
    let navigationController: UINavigationController
    private let container: DIContainer
    
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let authVC = container.makeAuthViewController(coordinator: self)
        
        navigationController.pushViewController(authVC, animated: true)
    }
    
    func completeAuth() {
        
        // 로그인 완료 시 필요한 비즈니스 로직들 추가
        print(#function)
        
        finishFlow?()
    }
}
