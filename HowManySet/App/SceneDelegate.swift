//
//  SceneDelegate.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import GoogleSignIn
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let container = DIContainer()
        let coordinator = AppCoordinator(window: window, container: container)
        self.appCoordinator = coordinator
        coordinator.start()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            
            if GIDSignIn.sharedInstance.handle(url) {
                return
            }
            
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
                return
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        LiveActivityService.shared.stop()
    }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}
