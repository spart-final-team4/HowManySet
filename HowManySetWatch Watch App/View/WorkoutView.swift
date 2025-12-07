//
//  WorkoutView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/29/25.
//

import SwiftUI

struct WorkoutView: View {
    
    let workout: Workout
    let workoutStartDate: Date
    
    @Binding var currentSet: Int
    @Binding var isResting: Bool
    
    private var isWorkoutFinished: Bool {
        currentSet >= workout.sets.count
    }
    
    private var currentSetInfoText: String {
        guard !workout.sets.isEmpty, !isWorkoutFinished else {
            return ""
        }
        let set = workout.sets[currentSet]
        let setWeight = set.weight.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", set.weight) : String(set.weight)
        return "\(setWeight)kg x \(set.reps)회"
    }
    
    private let buttonSize: CGFloat = 44
    private let pretendard = Pretendard()
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // 운동 시간 타이머
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .foregroundStyle(.brand)
                Text(timerInterval: workoutStartDate...Date.distantFuture, countsDown: false)
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .monospacedDigit()
                Spacer()
            }
            .padding(.horizontal, 8)
            
            VStack {
                VStack(spacing: 8) {
                    Text(workout.name)
                        .font(.custom(pretendard.pretendardSemiBold, size: 16))
                        .foregroundStyle(.white)
                    
                    Text(currentSetInfoText)
                        .font(.custom(pretendard.pretendardRegular, size: 14))
                        .foregroundStyle(isWorkoutFinished ? .green5 : .grey2)
                    
                    SetProgressBarForWatch(totalSets: workout.sets.count, currentSet: currentSet)
                        .padding(.horizontal, 8)
                }
                .frame(minHeight: 100)
            }
            
            Spacer()
            
            VStack {
                Button(action: handleSetComplete) {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                }
                .frame(width: buttonSize, height: buttonSize)
                .background(Circle().fill(isWorkoutFinished ? .disabledButton : .green6))
                .buttonStyle(.borderless)
                .disabled(isWorkoutFinished)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleSetComplete() {
        guard !isWorkoutFinished else { return }

        // 마지막 세트가 아닌 경우에만 휴식
        if currentSet < workout.sets.count - 1 {
            isResting = true
        }
        
        // 세트 수 증가
        currentSet += 1
    }
}
    
#Preview {
    WorkoutView(
        workout: Workout.mockData[0],
        workoutStartDate: Date.now,
        currentSet: .constant(4),
        isResting: .constant(false)
    )
}
