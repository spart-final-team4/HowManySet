//
//  ContentView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/26/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var exerciseName = "벤치 프레스"
    @State private var exerciseInfo = "60kg x 10회"
    @State private var currentSet = 2
    @State private var totalSet = 5
    @State private var weight = 60
    @State private var unit = "kg"
    @State private var reps = 10
    @State private var setProgress = 1
    
    private let pretendardBold = "Pretendard-Bold"
    private let pretendardSemiBold = "Pretendard-SemiBold"
    private let pretendardRegular = "Pretendard-Regular"
    private let buttonSize: CGFloat = 44
    
    var body: some View {
        TabView {
            VStack {
                HStack {
                    Text(timerInterval: Date.now...Date.distantFuture,
                         countsDown: false)
                    .font(.custom(pretendardRegular, size: 14))
                    .foregroundStyle(.grey3)
                    .monospacedDigit()
                    
                    Spacer()
                    
                    Text(Date.now, style: .time)
                        .font(.custom(pretendardRegular, size: 12))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }
                .scenePadding()
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text(exerciseName)
                        .font(.custom(pretendardSemiBold, size: 16))
                        .foregroundStyle(.white)
                    
                    Text(exerciseInfo)
                        .font(.custom(pretendardRegular, size: 14))
                        .foregroundStyle(.grey2)
                                        
                    SetProgressBarForWatch(totalSets: totalSet, currentSet: currentSet)
                }
                .scenePadding()
                
                Spacer()
                
                VStack {
                    Button {
                        print("세트완료 클릭")
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
                .scenePadding()
            }
        }//TabView
        .tabViewStyle(.page)
    }
}

#Preview {
    ContentView()
}
