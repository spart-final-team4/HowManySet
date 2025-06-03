//
//  AuthCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

final class AuthCoordinator: Coordinator {
    
    /// 로그인 완료 시 호출될 클로저
    var finishFlow: (() -> Void)?
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        <#code#>
    }
    
    func finishFlow() {
        
    }

}
