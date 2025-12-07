//
//  WorkoutCompleteView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 12/7/25.
//

import SwiftUI

struct WorkoutCompleteView: View {
        
    private let exerciseCompletedText = String(localized: "운동 완료! 수고했어요")
    private let pretendard = Pretendard()
    private let buttonSize: CGFloat = 44
    
    var body: some View {
        VStack(spacing: 20) {
            Text(exerciseCompletedText)
                .font(.custom(pretendard.pretendardRegular, size: 16))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            
            Button {
                
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .font(.system(size: 20))
            }
            .frame(width: buttonSize, height: buttonSize)
            .background(Circle().fill(.green6))
            .buttonStyle(.borderless)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WorkoutCompleteView()
}
