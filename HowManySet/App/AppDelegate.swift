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

        Thread.sleep(forTimeInterval: 2.0)
        
        // Firebase 초기화
        FirebaseApp.configure()
        
        // Google Sign-In 설정
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // 카카오 SDK 초기화
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
        // 카카오 로그인 처리
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
    
    // 앱 종료 시 라이브 액티비티 종료
    func applicationWillTerminate(_ application: UIApplication) {
        LiveActivityService.shared.stop()
    }
}
