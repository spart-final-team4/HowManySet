//
//  WorkoutView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/29/25.
//

import SwiftUI

struct WorkoutView: View {
    
    let workout: Workout
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
                        .foregroundStyle(isWorkoutFinished ? .green5 : .grey2)
                    
                    SetProgressBarForWatch(totalSets: workout.sets.count, currentSet: currentSet)
                }
                .frame(minHeight: 100)
            }
            
            Spacer()
            
            VStack {
                Button(action: handleSetComplete) {
                    if isWorkoutFinished {
                        // TODO: 마지막 운동까지 끝나면 전체 운동 완료 화면으로 전환 필요
                        Image(systemName: "flag.checkered")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .font(.system(size: 20))
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
                .disabled(isWorkoutFinished)
            }
        }
        .navigationTitle(Text(timerInterval: Date.now...Date.distantFuture, countsDown: false))
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
        currentSet: .constant(4),
        isResting: .constant(false)
    )
}
