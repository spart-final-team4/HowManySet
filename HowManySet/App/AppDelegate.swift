//
//  AppDelegate.swift
//  HowManySet
//
//  Created by GO on 5/30/25.
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
            
            // 스플래시 화면 노출 2초
            Thread.sleep(forTimeInterval: 2.0)
            
            // Firebase 초기화
            FirebaseApp.configure()
            
            if let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KakaoNativeAppKey") as? String {
                KakaoSDK.initSDK(appKey: kakaoAppKey)
            } else {
                fatalError("Check Your AppKey")
            }
            
            // 앱 시작 시 LiveActivity에 쓰이는 기존 운동 진행정보 UserDefaults 제거
            LiveActivityAppGroupEventBridge.shared.removeAppGroupEventValuesIfNeeded()
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 필요시 리소스 해제 등 처리
    }
}
