//
//  WorkoutView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/29/25.
//

import SwiftUI

struct WorkoutView: View {
    
    @State var workout: Workout
    
    // 운동 중 관련
    @State private var workoutStartDate: Date? = Date.now
    @State private var isWorkingout: Bool = true
    @State private var isWorkoutPaused: Bool = false
    @State private var currentSet = 0
    @State private var isWorkoutFinished = false
    
    @Binding var isResting: Bool
    @Binding var restStartDate: Date?
    
    private var currentSetInfoText: String {
        guard !workout.sets.isEmpty, currentSet >= 0, currentSet <
                workout.sets.count else {
            return "세트 정보 없음"
        }
        let set = workout.sets[currentSet]
        return "\(set.weight)kg x \(set.reps)회"
    }
    
    private let buttonSize: CGFloat = 44
    private let pretendard = Pretendard()
    
    var body: some View {
        VStack {
            VStack {
                VStack(spacing: 8) {
                    Text(workout.name)
                        .font(.custom(pretendard.pretendardSemiBold, size: 16))
                        .foregroundStyle(.white)
                    
                    Text(currentSetInfoText)
                        .font(.custom(pretendard.pretendardRegular, size: 14))
                        .foregroundStyle(.grey2)
                    
                    SetProgressBarForWatch(totalSets: workout.sets.count, currentSet: currentSet)
                }
                .frame(minHeight: 100)
            }
            
            Spacer()
            
            VStack {
                Button {
                    if isWorkoutFinished {
                        // TODO: 운동 완료 처리
                    } else {
                        if currentSet < workout.sets.count - 1 {
                            // 마지막 세트가 아님
                            currentSet += 1
                            isResting = true
                            restStartDate = Date.now
                        } else if currentSet == workout.sets.count - 1 {
                            // 마지막 세트 완료
                            currentSet += 1
                            isWorkoutFinished = true
                        }
                    }
                } label: {
                    if isWorkoutFinished {
                        Text("완료")
                            .font(.custom(pretendard.pretendardMedium, size: 14))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                    }
                }
                .frame(width: buttonSize, height: buttonSize)
                .background(Circle().fill(isWorkoutFinished ? .blue : .green6))
                .buttonStyle(.borderless)
            }
        }
        .navigationTitle(Text(timerInterval: Date.now...Date.distantFuture, countsDown: false))
        .navigationBarTitleDisplayMode(.inline)
    }
}
    


#Preview {
    WorkoutView(workout: Workout.mockData[0], isResting: .constant(false), restStartDate: .constant(Date.now))
}
