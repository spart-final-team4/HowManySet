import Foundation

/// Notification.Name + Extension으로 설정
/// 전역변수로 Notification.Name 설정
extension Notification.Name {
    /// RecordDetail 페이지에서 dismiss 했을 때 사용하는 Notification
    static let didDismissRecordDetail = Notification.Name("didDismissRecordDetail")
}
