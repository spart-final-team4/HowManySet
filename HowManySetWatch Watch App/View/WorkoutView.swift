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
    @State private var currentSet = 1
    @State private var restStartDate: Date?
    @State private var restTime: Float = 60
    @State private var isResting: Bool = false
    @State private var isRestPaused: Bool = false
    
    /// 휴식 종료 시간
    private var restEndDate: Date? {
        guard let restStartDate else { return nil }
        return restStartDate.addingTimeInterval(TimeInterval(restTime))
    }
    
    private var currentSetInfoText: String {
        guard !workout.sets.isEmpty, currentSet > 0, currentSet <=
                workout.sets.count else {
            return "세트 정보 없음"
        }
        let set = workout.sets[currentSet - 1]
        return "\(set.weight)kg x \(set.reps)회"
    }
    
    private let restText = String(localized: "휴식중")
    private let restSecondsLabelSize: CGFloat = 46
    private let buttonSize: CGFloat = 44
    private let pretendard = Pretendard()
    
    var body: some View {
        TabView {
            VStack {
                // MARK: Middle - 운동 정보 or 휴식정보
                if !isResting { // 운동 중
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
                } else {
                    VStack(spacing: 8) {
                        Text(restText)
                            .font(.custom(pretendard.pretendardRegular, size: 14))
                            .foregroundStyle(.grey2)
                        
                        if let restStartDate, let restEndDate {
                            Text(timerInterval: restStartDate...restEndDate, countsDown: true)
                                .font(.system(size: restSecondsLabelSize))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .monospacedDigit()
                        }
                    }
                    .frame(minHeight: 100)
                }
                
                Spacer()
                
                // MARK: Bottom - 조작 버튼
                VStack {
                    if !isResting { // 운동 중
                        Button {
                            print("세트완료 클릭")
                            
                            isResting.toggle()
                            restStartDate = Date.now
                        } label: {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                        }
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Circle().fill(.green6))
                        .buttonStyle(.borderless)
                    } else { // 휴식 중
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
                }
            }//VStack
            .scenePadding()
        }//TabView
        .tabViewStyle(.page)
        .navigationTitle(Text(timerInterval: Date.now...Date.distantFuture, countsDown: false))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        WorkoutView(workout: Workout.mockData[0])
    }
}
