import SwiftUI

struct RestSettingView: View {

    private let pretendard = Pretendard()
    private let restSetText = String(localized: "휴식 시간 설정")
    private let restSecondsLabelSize: CGFloat = 46

    @Binding var restTime: TimeInterval

    /// MM:SS 형태로 포맷팅된 휴식시간
    private var formattedRestTime: String {
        let minutes = Int(restTime) / 60
        let seconds = Int(restTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack {
            Text(restSetText)
                .font(.custom(pretendard.pretendardRegular, size: 12))
                .foregroundStyle(.grey3)

            Text(formattedRestTime)
                .font(.system(size: restSecondsLabelSize))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .monospacedDigit()

            HStack(spacing: 20) {
                Button {
                    restTime = max(30, restTime - 30)
                } label: {
                    Text("-30")
                        .font(.custom(pretendard.pretendardRegular, size: 20))
                        .foregroundStyle(.white)
                }
                .frame(width: 50, height: 50)
                .background(.disabledButton)
                .clipShape(Circle())

                Button {
                    restTime += 30
                } label: {
                    Text("+30")
                        .font(.custom(pretendard.pretendardRegular, size: 20))
                        .foregroundStyle(.white)
                }
                .frame(width: 50, height: 50)
                .background(.disabledButton)
                .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    RestSettingView(restTime: .constant(60))
}
