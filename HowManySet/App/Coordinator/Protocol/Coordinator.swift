//
//  Coordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol Coordinator: AnyObject {
    /// 시작 메서드로, Coordinator의 흐름을 시작
    func start()
}

extension Coordinator {
    /// 쌓여있는 뷰중 최상위 뷰를 찾아서 리턴
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController

        if let nav = baseVC as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = baseVC as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = baseVC?.presentedViewController {
            return topViewController(base: presented)
        }
        return baseVC
    }
    /// 현재 뷰에서 presentModal
    func presentModal(_ vc: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async {
            guard let topVC = self.topViewController() else { return }
            topVC.present(vc, animated: animated)
        }
    }

    func popToRootViewController(animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            var root = self?.topViewController()?.presentingViewController
            
            while let parent = root?.presentingViewController {
                root = parent
            }
            root?.dismiss(animated: true)
        }
    }
}
