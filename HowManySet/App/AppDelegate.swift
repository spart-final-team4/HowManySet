//
//  AppDelegate.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Firebase 초기화
            FirebaseApp.configure()
            
            if let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KakaoNativeAppKey") as? String {
                KakaoSDK.initSDK(appKey: kakaoAppKey)
            } else {
                fatalError("Check Your AppKey")
            }
        
        return true
    }
    
    // 구글/카카오 인증 결과 처리 (iOS 13 이상, SceneDelegate 병행 사용)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        // 구글 로그인 처리
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        // 카카오 로그인 처리
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // 기본 SceneDelegate 사용
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // 필요시 리소스 해제 등 처리
    }
}
