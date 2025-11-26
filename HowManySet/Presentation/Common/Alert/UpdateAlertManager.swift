import UIKit

final class UpdateAlertManager {

    // App id
    private let appId: String = "6746778243"

    // App Store 최신 버전 조회 (iTunes lookup API)
    func checkAppStoreVersion() async -> String {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appId)") else { return "" }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
               let results = json["results"] as? [[String: Any]],
               let appStoreVersion = results[0]["version"] as? String { return appStoreVersion }
        } catch {
            print("앱스토어 버전을 가져오지 못했습니다❌ \(error)")
        }

        return ""
    }

    // 현재 번들 버전 확인
    func checkBundleVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        return version
    }

    // Semantic Version 비교하여 업데이트가 필요한지 판단 (Major -> Minor -> Patch)
    func checkUpdateAlertNeeded() async -> UpdateAlertType? {
        let bundleVersion = checkBundleVersion()
        let appStoreVersion = await checkAppStoreVersion()

        let bundleVersionArray = bundleVersion.split(separator: ".").map { $0 }
        let appStoreVersionArray = appStoreVersion.split(separator: ".").map { $0 }

        if bundleVersionArray[0] < appStoreVersionArray[0] {
            return .majorUpdate
        } else if bundleVersionArray[0] == appStoreVersionArray[0]
                     && bundleVersionArray[1] < appStoreVersionArray[1] {
            return .minorUpdate
        } else if bundleVersionArray[0] == appStoreVersionArray[0]
                     && bundleVersionArray[1] == appStoreVersionArray[1]
                     && bundleVersionArray[2] < appStoreVersionArray[2] {
            return .patchUpdate
        } else {
            return nil
        }
    }

    // 업데이트 alert를 표시하는 메서드
    func showUpdateAlert(type: UpdateAlertType, on viewController: UIViewController) {
        let alertVC = UIAlertController(title: type.title, message: type.message, preferredStyle: .alert)

//        // 선택이라면 "다음에" 허용
//        alertVC.addAction(UIAlertAction(title: String(localized: "다음에"), style: .default))

        // "업데이트"
        alertVC.addAction(UIAlertAction(title: String(localized: "업데이트"), style: .default, handler: { _ in
            let urlStr = "itms-apps://itunes.apple.com/app/\(self.appId)"
            if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }))

        viewController.present(alertVC, animated: true)
    }
}
