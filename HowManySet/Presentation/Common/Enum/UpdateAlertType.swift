import Foundation

/// Semantic Version에 따라 업데이트를 진행하고 있으므로, 추후에 버전 업데이트마다 Alert를 다르게 표시하기 위한 열거형입니다.
enum UpdateAlertType {
    case patchUpdate
    case minorUpdate
    case majorUpdate

    var title: String {
        switch self {
        case .patchUpdate:
            return String(localized: "패치 업데이트 알림")
        case .minorUpdate:
            return String(localized: "마이너 업데이트 알림")
        case .majorUpdate:
            return String(localized: "메이저 업데이트 알림")
        }
    }

    var message: String {
        switch self {
        case .patchUpdate:
            return String(localized: "HowManySet이 개선되었어요!\n 바로 패치 업데이트해 보세요")
        case .minorUpdate:
            return String(localized: "HowManySet이 개선되었어요!\n 바로 마이너 업데이트해 보세요")
        case .majorUpdate:
            return String(localized: "HowManySet이 개선되었어요!\n 바로 메이저 업데이트해 보세요")
        }
    }
}
