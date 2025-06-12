//
//  MyPageCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit
import SafariServices

protocol MyPageCoordinatorProtocol: Coordinator {
    func presentLanguageSettingAlert()
    func pushAlarmSettingView()
    func showVersionInfo()
    func openAppStoreReviewPage()
    func presentPrivacyPolicyView()
    func presentReportProblemView()
    func alertLogout()
    func pushAccountWithdrawalView()
}

/// 마이페이지 흐름 담당 coordinator
/// 각 세부 설정, 계정 관련 present/push 처리
final class MyPageCoordinator: MyPageCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer
    
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
    
    /// 언어 변경
    /// 알림 설정
    /// 앱 평가
    /// 버전 정보
    /// 개인정보처리방침
    /// 문제제보
    /// 계정탈퇴
    /// -----------------
    /// 팝업: 무게 단위 설정
    /// 설정으로 이동: 언어 변경
    /// View Push: 알림 설정
    /// alert: 버전정보
    
    
    /// 프로필 설정 창 push
    func pushProfileSettingView() {
        
    }
    
    /// 회원전환 or 로그아웃 시 뷰 스택 초기화 후 로그인 화면으로
    func navigateToAuthView() {
        // TODO: 회원전환 로직
        // TODO: 로그아웃 로직
        
        let authCoordinator = AuthCoordinator(navigationController: navigationController, container: container)
        let authVC = container.makeAuthViewController(coordinator: authCoordinator)
        
        navigationController.setViewControllers([authVC], animated: false)
    }
    
    /// 언어 변경 처리 (설정 앱 이동 알림)
    func presentLanguageSettingAlert() {
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

        navigationController.present(alert, animated: true)
    }
    
    /// 알림 설정 창 or 커스텀 알림 설정 포함한 새로운 뷰로 이동
    func pushAlarmSettingView() {
        let alert = UIAlertController(
            title: "알림 설정",
            message: "알림은 설정 앱에서 변경할 수 있어요.\n앱 설정으로 이동할까요?",
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

        navigationController.present(alert, animated: true)
    }
    
    /// Alert로 버전 정보 표시
    func showVersionInfo() {
        // 버전 정보 받아오기
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "알 수 없음"
        
        let alert = UIAlertController(title: "버전 정보", message: "앱 버전: \(version)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        navigationController.present(alert, animated: true)
    }
    /// 앱스토러에 등록된 앱의 버전 불러오기
    private func getAppStoreVersion() -> String? {
        let appLink = ""
        let url = URL(string: appLink)!
        let data = try? Data(contentsOf: url)
        if data == nil { return nil }
        let json = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
        let results = json?["results"] as? [[String: Any]]
        if (results?.count ?? -1) > 0 {
            return results![0]["version"] as? String
        }
        return nil
    }
    
    /// 앱스토어 리뷰 작성 페이지로 이동
    func openAppStoreReviewPage() {
        // 추후에 url 설정 필요
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /// 개인정보처리방침 링크로 이동
    func presentPrivacyPolicyView() {
        // 추후에 url 설정 필요
        guard let url = URL(string: "개인정보처리방침 링크") else { return }
        let safariVC = SFSafariViewController(url: url)
        
        navigationController.present(safariVC, animated: true)
    }
    
    /// 문제제보 링크로 이동
    func presentReportProblemView() {
        // 추후에 url 설정 필요
        guard let url = URL(string: "문제제보 링크") else { return }
        let safariVC = SFSafariViewController(url: url)
        
        navigationController.present(safariVC, animated: true)
    }
    
    func alertLogout() {
        let deleteAccountVC = DefaultPopupViewController(title: "로그아웃 하시겠습니까?", content: "", okButtonText: "로그아웃") {
            print("로그아웃")
        }
        navigationController.present(deleteAccountVC, animated: true)
    }
    
    /// 계정 삭제 시 단순 alert? or View?
    func pushAccountWithdrawalView() {
        // TODO: 계정 삭제 로직
        let deleteAccountVC = DefaultPopupViewController(title: "정말 탈퇴하시겠습니까?", content: "탈퇴 시 모든 운동 기록과 데이터가 삭제되며, 복구할 수 없습니다.", okButtonText: "계정 삭제") {
            print("계정 삭제")
        }
        navigationController.present(deleteAccountVC, animated: true)
    }
    
    
}
