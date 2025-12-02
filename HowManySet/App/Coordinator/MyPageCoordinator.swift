//
//  MyPageCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit
import SafariServices
import AcknowList

protocol MyPageCoordinatorProtocol: Coordinator {
    func presentLanguageSettingAlert()
    func pushAlarmSettingView()
    func showVersionInfo()
    func openAppStoreReviewPage()
    func presentPrivacyPolicyView()
    func alertLogout()
    func pushAccountWithdrawalView()
    func navigateToAuth()
    func presentLicenseView()
    func presentMembershipView()
    
    var modelName: String { get }
}

/// 마이페이지 흐름 담당 coordinator
/// 각 세부 설정, 계정 관련 present/push 처리
final class MyPageCoordinator: MyPageCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer
    /// 앱 ID
    private let appID = "6746778243"
    
    /// 로그아웃/계정삭제 완료 시 호출할 클로저
    var finishFlow: (() -> Void)?
    
    /// 로그아웃, 계정탈퇴 중복 방지
    var isMovingToAuth = false

    /// coordinator 생성자
    /// - Parameters:
    ///   - navigationController: 네비게이션 컨트롤러
    ///   - container: DI 컨테이너
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    /// 시작, 마이페이지 뷰 푸시
    func start() {
        let myPageVC = container.makeMyPageViewController(coordinator: self)
        navigationController.pushViewController(myPageVC, animated: true)
    }
    
    /// 언어 변경 처리 (설정 앱 이동 알림)
    func presentLanguageSettingAlert() {
        let alert = UIAlertController(
            title: String(localized: "언어 변경"),
            message: String(localized: "언어는 설정 앱에서 변경할 수 있어요.\n앱 설정으로 이동할까요?"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: String(localized: "취소"), style: .destructive, handler: nil))

        alert.addAction(UIAlertAction(title: String(localized: "이동"), style: .default) { _ in
            // 앱 설정 화면으로 이동
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })

        navigationController.present(alert, animated: true)
    }
    
    /// 알림 설정 창 or 커스텀 알림 설정 포함한 새로운 뷰로 이동
    func pushAlarmSettingView() {
        let alert = UIAlertController(
            title: String(localized: "알림 설정"),
            message: String(localized: "알림은 설정 앱에서 변경할 수 있어요.\n앱 설정으로 이동할까요?"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localized: "취소"), style: .destructive, handler: nil))

        alert.addAction(UIAlertAction(title: String(localized: "이동"), style: .default) { _ in
            // 앱 설정 화면으로 이동
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })

        navigationController.present(alert, animated: true)
    }
    
    /// Alert로 버전 정보 표시
    func showVersionInfo() {
        // 버전 정보 받아오기
        getAppStoreVersion { appstoreVersion in
            DispatchQueue.main.async {
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                if let appstoreVersion, appstoreVersion != currentVersion {
                    let needToUpdatePopupVC = DefaultPopupViewController(title: String(localized: "최신버전이 아닙니다."),
                                                                         titleTextColor: .success,
                                                                         content: String(localized: "최신버전으로 업데이트 하시겠습니까?\n(업데이트 클릭 시 앱스토어로 연결됩니다.)"),
                                                                         okButtonText: String(localized: "업데이트"),
                                                                         okButtonBackgroundColor: .success
                    ) {
                        // TODO: 앱스토어 앱 페이지로 이동 URL 입력 필요
                        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(self.appID)"),
                              UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    self.navigationController.present(needToUpdatePopupVC, animated: true)
                } else {
                    let versionString = currentVersion ?? "알 수 없음"
                    let alert = UIAlertController(title: String(localized: "버전 정보"), message: String(localized: "앱 버전: \(versionString)"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: String(localized: "확인"), style: .default))
                    self.navigationController.present(alert, animated: true)
                }
            }
        }
    }
    
    /// 앱스토어 리뷰 작성 페이지로 이동
    func openAppStoreReviewPage() {
        // TODO: 추후에 url 설정 필요
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /// 개인정보처리방침 링크로 이동
    func presentPrivacyPolicyView() {
        let webVC = PrivacyWebViewController()
        navigationController.present(webVC, animated: true)
    }
    
    /// 버전정보
    var modelName: String {
        return self.getModelName()
    }
    /// 로그아웃 팝업 표시 및 Reactor 액션 연결
    func alertLogout() {
        // MyPageViewController에서 Reactor를 통해 로그아웃 처리하도록 수정
        guard let myPageVC = navigationController.viewControllers.last as? MyPageViewController else { return }
        
        let deleteAccountVC = DefaultPopupViewController(title: String(localized: "로그아웃 하시겠습니까?"),
                                                         okButtonText: String(localized: "로그아웃")) {
            // Reactor의 confirmLogout 액션 호출
            myPageVC.reactor?.action.onNext(.confirmLogout)
        }
        navigationController.present(deleteAccountVC, animated: true)
    }
    
    /// 계정 삭제 팝업 표시 및 Reactor 액션 연결
    func pushAccountWithdrawalView() {
        guard let myPageVC = navigationController.viewControllers.last as? MyPageViewController else { return }
        
        let deleteAccountVC = DefaultPopupViewController(title: String(localized: "정말 탈퇴하시겠습니까?"),
                                                         content: String(localized: "탈퇴 시 모든 운동 기록과 데이터가 삭제되며, 복구할 수 없습니다."),
                                                         okButtonText: String(localized: "계정 삭제")) {
            // Reactor의 confirmDeleteAccount 액션 호출
            myPageVC.reactor?.action.onNext(.confirmDeleteAccount)
        }
        navigationController.present(deleteAccountVC, animated: true)
    }
    
    /// 인증 화면으로 이동 (로그아웃/계정삭제 후)
    func navigateToAuth() {
        guard !isMovingToAuth else { return }
        isMovingToAuth = true
        
        print("🟢 로그아웃/계정삭제 후 상태 완전 초기화")
        
        // 모든 상태 완전 초기화
        let keysToRemove = [
            "hasCompletedOnboarding",
            "hasSkippedOnboarding",
            "userNickname",
            "userProvider",
            "userUID",
            "hasSetNickname"
        ]
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        finishFlow?()
    }
    
    func presentLicenseView() {
        let licenseView = AcknowListViewController()
        licenseView.title = String(localized: "라이센스 정보")
        navigationController.pushViewController(licenseView, animated: true)
    }
    
    func presentMembershipView() {
        let membershipView = container.makeMembershipView()
        
        topViewController()?.present(membershipView, animated: true)
    }
}

private extension MyPageCoordinator {
    /// 앱스토러에 등록된 앱의 버전 불러오기
    func getAppStoreVersion(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "itms-apps://itunes.apple.com/lookup?id\(appID)") else {
            completion(nil)
            return
        }

        // 비동기 네트워크 요청
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                error == nil,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let results = json["results"] as? [[String: Any]],
                let firstResult = results.first,
                let version = firstResult["version"] as? String
            else {
                completion(nil)
                return
            }
            completion(version)
        }
        task.resume()
    }
    
    func getModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let model = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch model {
            // Simulator
            case "i386", "x86_64", "arm64":                 return "Simulator"
            
            // iPod
            case "iPod1,1":                                 return "iPod Touch"
            case "iPod2,1", "iPod3,1", "iPod4,1":           return "iPod Touch"
            case "iPod5,1", "iPod7,1":                      return "iPod Touch"
            
            // iPad
            case "iPad1,1":                                 return "iPad"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2nd Gen"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
            
            // iPhone
            case "iPhone1,1", "iPhone1,2", "iPhone2,1":     return "iPhone"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE 2nd Gen"
            case "iPhone13,1":                              return "iPhone 12 Mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPhone14,4":                              return "iPhone 13 Mini"
            case "iPhone14,5":                              return "iPhone 13"
            case "iPhone14,2":                              return "iPhone 13 Pro"
            case "iPhone14,3":                              return "iPhone 13 Pro Max"
            case "iPhone14,6":                              return "iPhone SE 3rd Gen"
            case "iPhone15,2":                              return "iPhone 14"
            case "iPhone15,3":                              return "iPhone 14 Plus"
            case "iPhone15,4":                              return "iPhone 14 Pro"
            case "iPhone15,5":                              return "iPhone 14 Pro Max"
            case "iPhone16,1":                              return "iPhone 15"
            case "iPhone16,2":                              return "iPhone 15 Plus"
            case "iPhone16,3":                              return "iPhone 15 Pro"
            case "iPhone16,4":                              return "iPhone 15 Pro Max"
            case "iPhone17,1":                              return "iPhone 16"
            case "iPhone17,2":                              return "iPhone 16 Plus"
            case "iPhone17,3":                              return "iPhone 16 Pro"
            case "iPhone17,4":                              return "iPhone 16 Pro Max"
            
            default:                                        return model
        }
    }
}
