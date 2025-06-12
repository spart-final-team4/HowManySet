import Foundation

extension Date {
    /// 주어진 총 시간(초단위)를 기준으로 시작 시간을 계산하여 반환하는 메서드
    func startTime(fromTotalTime totalTime: Int) -> Date {
        Calendar.current.date(byAdding: .second, value: -totalTime, to: self) ?? self
    }

    /// Date에서 "HH:mm" 형태의 String으로 반환하는 메서드
    func toTimeLabel() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    /// Date에서 "MM-dd" 형태의 String으로 반환하는 메서드
    func toDateLabel() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: self)
    }
}
