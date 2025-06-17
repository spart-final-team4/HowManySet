import Foundation

extension Double {
    /// 소수점이 .0으로 딱 떨어지면 정수로, 그 외에는 그대로 문자열 반환
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", self) :
            String(self)
    }
}
