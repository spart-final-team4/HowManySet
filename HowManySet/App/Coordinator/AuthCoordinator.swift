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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let authVC = AuthViewController(reactor: AuthViewReactor())
        
        navigationController.pushViewController(authVC, animated: true)
    }
    
    func completeAuth() {
        
        // 로그인 완료 시 필요한 비즈니스 로직들 추가
        print(#function)
        
        finishFlow?()
    }
}
