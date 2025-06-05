//
//  MyPageCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol MyPageCoordinatorProtocol: Coordinator {
    
}

final class MyPageCoordinator: MyPageCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer
    
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let myPageVC = container.makeMyPageViewController(coordinator: self)
        
        navigationController.pushViewController(myPageVC, animated: true)
    }
    /// 언어 변경 처리 (설정 앱 이동 알림)
    func presentLanguageSettingAlert(from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "언어 변경",
            message: "언어는 설정 앱에서 변경할 수 있어요.\n앱 설정으로 이동할까요?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "이동", style: .default) { _ in
            // 앱 설정 화면으로 이동
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })

        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        viewController.present(alert, animated: true)
    }
    /// Alert로 버전 정보 표시
    func showVersionInfo(from viewController: UIViewController) {
        // 버전 정보 받아오기
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "알 수 없음"
        
        let alert = UIAlertController(title: "버전 정보", message: "앱 버전: \(version)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        viewController.present(alert, animated: true)
    }
}
