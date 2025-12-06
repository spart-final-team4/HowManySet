//
//  RoutineInfoView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/29/25.
//

import SwiftUI

struct RoutineInfoView: View {
    
    private let pretendard = Pretendard()
    @State var routine: WorkoutRoutine
    @State var showStartsButton = false
//    @State private var isWorkoutActive = false
    private let startBtnText = "운동시작"
    
    var body: some View {
        VStack(spacing: 8) {
            // 운동 리스트
            List {
                ForEach(routine.workouts) { workout in
                    HStack {
                        Text(workout.name)
                            .font(.custom(pretendard.pretendardRegular, size: 12))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(workout.sets.count)set")
                            .font(.custom(pretendard.pretendardRegular, size: 12))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 2)
                }
            }
            .listStyle(.carousel)
            .navigationTitle(routine.name)
            .navigationBarTitleDisplayMode(.inline)
            
            if showStartsButton {
                NavigationLink {
                    SessionPagingView(routine: routine)
                } label: {
                    Text(startBtnText)
                        .font(.custom(pretendard.pretendardMedium, size: 14))
                        .foregroundColor(.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.green6)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 8)
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationView {
        RoutineInfoView(routine: WorkoutRoutine.mockData[0], showStartsButton: true)
    }
}
