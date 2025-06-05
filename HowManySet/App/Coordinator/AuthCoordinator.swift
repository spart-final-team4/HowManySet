//
//  AuthCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol AuthCoordinatorProtocol: Coordinator {
    
}

/// 인증 흐름 담당 coordinator
/// 로그인 화면 표시 후 완료 시 finishFlow 호출로 흐름 전환
final class AuthCoordinator: AuthCoordinatorProtocol {
    /// 로그인 완료 시 호출 클로저
    var finishFlow: (() -> Void)?
    /// 인증 흐름에서 사용할 navigation controller
    let navigationController: UINavigationController
    /// 의존성 주입 컨테이너
    private let container: DIContainer

    /// coordinator 생성자
    /// - Parameters:
    ///   - navigationController: 인증 흐름용 navigation
    ///   - container: DI 컨테이너
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    /// 인증 흐름 시작 후 로그인 화면 push
    func start() {
        let authVC = container.makeAuthViewController(coordinator: self)
        navigationController.pushViewController(authVC, animated: true)
    }

    /// 로그인 완료 시 호출
    /// 후처리 로직 추가 후 finishFlow 호출
    func completeAuth() {
        // 비즈니스 로직 추가
        print(#function)
        finishFlow?()
    }
}
