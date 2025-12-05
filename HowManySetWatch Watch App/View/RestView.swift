//
//  RestView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/30/25.
//

import SwiftUI

struct RestView: View {
    
    @State private var restTime: Float = 60
    @State private var isRestPaused: Bool = false
    @State private var remainingTime: TimeInterval = 60
    
    @Binding var restStartDate: Date?
    @Binding var isResting: Bool
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                    print("휴식 스킵")
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
                    print("휴식 정지/재생")
                    isRestPaused.toggle()
                } label: {
                    Image(systemName: isRestPaused ? "play.fill" : "pause.fill")
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
        .onAppear {
            self.remainingTime = TimeInterval(restTime)
        }
        .onReceive(timer) { _ in
            guard isResting, !isRestPaused else { return }
            
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                isResting = false
            }
        }
    }
}

#Preview {
    RestView(restStartDate: .constant(Date.now), isResting: .constant(false))
}
