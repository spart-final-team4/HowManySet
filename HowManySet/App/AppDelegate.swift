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
import UserNotifications
import RealmSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            Thread.sleep(forTimeInterval: 2.0)
            
            // Firebase 초기화
            FirebaseApp.configure()
            // 앱 시작 시 LiveActivity에 쓰이는 기존 운동 진행정보 UserDefaults 제거
            LiveActivityAppGroupEventBridge.shared.removeAppGroupEventValuesIfNeeded()
            // UNUserNotificationCenterDelegate 설정
            UNUserNotificationCenter.current().delegate = self
            // 알람 권한 요청
            NotificationService.shared.requestNotification()
            // Realm 파일 위치 프린트
            print("## realm file dir -> \(Realm.Configuration.defaultConfiguration.fileURL!)")
            
            // 세션-로컬 상태 불일치 시 강제 로그아웃 처리
            if let user = Auth.auth().currentUser {
                let provider = UserDefaults.standard.string(forKey: "userProvider")
                let hasSetNickname = UserDefaults.standard.bool(forKey: "hasSetNickname")
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                
                // 유저는 로그인 상태인데 UserDefaults가 모두 초기값이면 비정상 세션으로 판단
                if (provider == nil || provider == "none" || provider?.isEmpty == true)
                    && !hasSetNickname && !hasCompletedOnboarding {
                    print("⚠️ Firebase 유저는 존재하지만 로컬 상태 없음 - 강제 로그아웃 및 초기화")
                    
                    // Firebase 로그아웃
                    try? Auth.auth().signOut()
                    
                    // UserDefaults 전체 초기화
                    if let bundleId = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: bundleId)
                        UserDefaults.standard.synchronize()
                    }
                }
            }
            
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 앱이 foreground일 때 알림 보여주기
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
