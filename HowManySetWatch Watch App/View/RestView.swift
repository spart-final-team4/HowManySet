//
//  RestView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/30/25.
//

import SwiftUI

struct RestView: View {
    
    @Binding var remainingTime: TimeInterval
    @Binding var isResting: Bool
    @Binding var isPaused: Bool
    
    private let restText = String(localized: "휴식중")
    private let restSecondsLabelSize: CGFloat = 46
    private let buttonSize: CGFloat = 44
    private let pretendard = Pretendard()
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(restText)
                .font(.custom(pretendard.pretendardRegular, size: 14))
                .foregroundStyle(.grey2)
            
            Text(formatTime(remainingTime))
                .font(.system(size: restSecondsLabelSize))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .monospacedDigit()
            
            HStack(spacing: 30) {
                Button {
                    isResting = false
                } label: {
                    Image(systemName: "forward.end.fill")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                }
                .frame(width: buttonSize, height: buttonSize)
                .background(Circle().fill(.green6))
                .buttonStyle(.borderless)
                
                Button {
                    isPaused.toggle()
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                }
                .frame(width: buttonSize, height: buttonSize)
                .background(Circle().fill(.roundButtonBG))
                .buttonStyle(.borderless)
            }
        }
        .frame(minHeight: 100)
    }
}

#Preview {
    RestView(
        remainingTime: .constant(60),
        isResting: .constant(true),
        isPaused: .constant(false)
    )
}
