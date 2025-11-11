//
//  HowManySetLiveActivityLiveActivity.swift
//  HowManySetLiveActivity
//
//  Created by 정근호 on 5/30/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HowManySetWidgetAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        // state

        // 운동 중 관련
        var workoutTime: Int /// 운동 정지/재생 시 업데이트
        var isWorkingout: Bool
        var isWorkoutPaused: Bool

        var exerciseName: String
        var exerciseInfo: String
        var currentRoutineCompleted: Bool

        // 휴식 중 관련
        var restStartDate: Date?
        var liveRestTime: Float
        var isResting: Bool
        var isRestPaused: Bool

        // 세트 관련
        var currentSet: Int
        var totalSet: Int
        var currentIndex: Int

        /// 운동 타이머 표시용 시작 시간
        var workoutStartDate: Date?

        /// 휴식 종료 시간
        var restEndDate: Date? {
            guard let restStartDate else { return nil }
            return restStartDate.addingTimeInterval(TimeInterval(liveRestTime))
        }
    }
    
    // Fixed non-changing properties about your activity go here!
    // attributes
}

struct HowManySetWidgetLiveActivity: Widget {
    
    private let buttonSize: CGFloat = 54
    private let buttonSizeAtDynamic: CGFloat = 44
    private let restSecondsRemainigLabelSize: CGFloat = 46
    private let restText = String(localized: "휴식")
    private let completeText = String(localized: "모든 운동을 완료하셨습니다!")
    private let pretendardBold = "Pretendard-Bold"
    private let pretendardSemiBold = "Pretendard-SemiBold"
    private let pretendardRegular = "Pretendard-Regular"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HowManySetWidgetAttributes.self) { context in

            // Lock screen/banner UI goes here
            VStack {
                if !context.state.currentRoutineCompleted {
                    VStack(alignment: .leading, spacing: 10) {
                        if let workoutStartDate = context.state.workoutStartDate,
                           !context.state.isResting { // 운동 중 상단
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundStyle(.brand)
                                Text(timerInterval: workoutStartDate...Date.distantFuture,
                                     countsDown: false)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .monospacedDigit()
                            }
                        } else { // 휴식 중 상단
                            HStack {
                                Image(systemName: "dumbbell")
                                    .foregroundStyle(.brand)
                                Text(String(context.state.exerciseName))
                                    .foregroundStyle(.white)
                                    .font(.custom(pretendardSemiBold, size: 14))
                            }
                        }
                        // MARK: - 운동 중 contents
                        if !context.state.isResting { // 운동 중 가운데 (운동정보)
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(context.state.exerciseName)
                                        .font(.custom(pretendardBold, size: 20))
                                        .foregroundStyle(.white)
                                    Text(context.state.exerciseInfo)
                                        .font(.custom(pretendardRegular, size: 16))
                                        .foregroundStyle(.grey2)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 10) { // 운동 중 버튼
                                    if #available(iOS 17.0, *) {
                                        Button(intent: SetCompleteIntent(index: context.state.currentIndex)) {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.brand)
                                                .fontWeight(.bold)
                                                .font(.title2)
                                        }
                                        .frame(width: buttonSize, height: buttonSize)
                                        .background(Circle().fill(.green10))
                                        .buttonStyle(.borderless)
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                    // TODO: 운동 완료 버튼 현재 비활 (추후 활성화 할 수도 있음)
                                    //                                if #available(iOS 17.0, *) {
                                    //                                    Button(intent: StopWorkoutIntent(index: context.state.currentIndex)) {
                                    //                                        Image(systemName: "xmark")
                                    //                                            .foregroundStyle(.white)
                                    //                                            .fontWeight(.bold)
                                    //                                            .font(.title3)
                                    //                                    }
                                    //                                    .frame(width: buttonSize, height: buttonSize)
                                    //                                    .background(Circle().fill(Color("RoundButtonBG")))
                                    //                                    .buttonStyle(.borderless)
                                    //                                } else {
                                    //                                    // Fallback on earlier versions
                                    //                                }
                                }
                            }
                        }
                        // MARK: - 휴식 중 contents
                        else {
                            HStack {
                                HStack(alignment: .lastTextBaseline, spacing: 5) {
                                    Text(restText)
                                        .font(.custom(pretendardBold, size: 16).weight(.bold))
                                        .foregroundStyle(.brand)
                                               
                                    if let restStartDate = context.state.restStartDate, let restEndDate = context.state.restEndDate { // 휴식 타이머
                                        if !context.state.isRestPaused {
                                            Text(timerInterval: restStartDate...restEndDate, countsDown: true)
                                                .font(.system(size: restSecondsRemainigLabelSize))
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.white)
                                                .monospacedDigit()
                                        } else {
                                            Text(Int(round(context.state.liveRestTime)).toRestTimeLabelInLive())
                                                .font(.system(size: restSecondsRemainigLabelSize))
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.white)
                                                .monospacedDigit()
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 10) {
                                    if #available(iOS 17.0, *) {
                                        Button(intent: SkipIntent(index: context.state.currentIndex)) {
                                            Image(systemName: "forward.end.fill")
                                                .foregroundStyle(.brand)
                                                .fontWeight(.semibold)
                                                .font(.title2)
                                        }
                                        .frame(width: buttonSize, height: buttonSize)
                                        .background(Circle().fill(Color("green10")))
                                        .buttonStyle(.borderless)
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                    
                                    if #available(iOS 17.0, *) {
                                        Button(intent: PlayAndPauseRestIntent()) {
                                            Image(systemName: context.state.isRestPaused ? "play.fill" : "pause.fill")
                                                .foregroundStyle(.white)
                                                .fontWeight(.semibold)
                                                .font(.title2)
                                        }
                                        .frame(width: buttonSize, height: buttonSize)
                                        .background(Circle().fill(Color("RoundButtonBG")))
                                        .buttonStyle(.borderless)
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                    
                                }
                            }
                        }
                        // MARK: - ProgressBar
                        SetProgressBarForLiveActivity(
                            totalSets: context.state.totalSet,
                            currentSet: context.state.currentSet
                        )
                        .frame(maxWidth: .infinity, maxHeight: 14)
                    }
                } else { // 현재 루틴의 모든 운동 완료 시
                    HStack(alignment: .center, spacing: 20) {
                        Image(systemName: "dumbbell.fill")
                            .foregroundStyle(.brand)
                            .fontWeight(.semibold)
                            .font(.title)
                        Text(completeText)
                            .font(.custom(pretendardSemiBold, size: 18))
                            .foregroundStyle(.white)
                        Image(systemName: "chevron.right.2")
                            .foregroundStyle(.brand)
                            .fontWeight(.semibold)
                            .font(.title)
                    }//HStack
                    .frame(maxWidth: .infinity)
                }//else
            }
            .padding(.all, 18)
            .frame(height: 170)
            .background(Color("Background"))
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: - DynamicIsland Expanded
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        if !context.state.currentRoutineCompleted {
                            if !context.state.isResting {
                                Image(systemName: "dumbbell")
                                    .foregroundStyle(.brand)
                                    .font(.largeTitle)
                            } else {
                                Image(systemName: "timer")
                                    .foregroundStyle(.brand)
                                    .font(.largeTitle)
                            }
                        } else {
                            Image(systemName: "dumbbell.fill")
                                .foregroundStyle(.brand)
                                .font(.largeTitle)
                        }
                    }
                    .padding(.leading, 12)
                    .padding(.top, 24)
                }
                DynamicIslandExpandedRegion(.center) {
                    if !context.state.currentRoutineCompleted {
                        if !context.state.isResting {
                            HStack(spacing: 12) {
                                Text(context.state.exerciseName)
                                    .font(.custom(pretendardSemiBold, size: 22))
                                    .foregroundStyle(.white)
                                Text("\(context.state.currentSet)/\(context.state.totalSet)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.grey3)
                                    .monospacedDigit()
                            }
                            .padding(.top, 10)
                            Spacer()
                        } else {
                            HStack(spacing: 12) {
                                Text(restText)
                                    .font(.custom(pretendardSemiBold, size: 22))
                                    .foregroundStyle(.white)
                                Text("\(context.state.currentSet)/\(context.state.totalSet)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.grey3)
                                    .monospacedDigit()
                            }
                            .padding(.top, 10)
                            .padding(.trailing, 40)
                            Spacer()
                        }
                    } else {
                        Text(completeText)
                            .font(.custom(pretendardSemiBold, size: 18))
                            .foregroundStyle(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Group {
                        if !context.state.currentRoutineCompleted {
                            if !context.state.isResting {
                                if #available(iOS 17.0, *) {
                                    Button(intent: SetCompleteIntent(index: context.state.currentIndex)) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.brand)
                                            .fontWeight(.bold)
                                            .font(.system(size: 20))
                                    }
                                    .frame(width: buttonSizeAtDynamic, height: buttonSizeAtDynamic)
                                    .background(Circle().fill(.green10))
                                    .buttonStyle(.borderless)
                                } else {
                                    // Fallback on earlier versions
                                }
                            } else {
                                if #available(iOS 17.0, *) {
                                    Button(intent: SkipIntent(index: context.state.currentIndex)) {
                                        Image(systemName: "forward.end.fill")
                                            .foregroundStyle(.brand)
                                            .fontWeight(.semibold)
                                            .font(.system(size: 20))
                                    }
                                    .frame(width: buttonSizeAtDynamic, height: buttonSizeAtDynamic)
                                    .background(Circle().fill(Color("green10")))
                                    .buttonStyle(.borderless)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                        } else {
                            Image(systemName: "chevron.right.2")
                                .foregroundStyle(.brand)
                                .fontWeight(.semibold)
                                .font(.largeTitle)
                        }
                    }//Group
                    .padding(.trailing, 12)
                    .padding(.top, 24)
                }
            }
            // MARK: - compact
            compactLeading: {
                if !context.state.currentRoutineCompleted {
                    Group {
                        if !context.state.isResting {
                            Image(systemName: "dumbbell")
                                .foregroundStyle(.brand)
                        } else {
                            Image(systemName: "timer")
                                .foregroundStyle(.brand)
                        }
                        
                    }
                    .padding(.leading, 12)
                    .padding(.vertical, 7)
                } else {
                    Image(systemName: "dumbbell.fill")
                        .foregroundStyle(.brand)
                        .padding(.leading, 12)
                        .padding(.vertical, 7)
                }
            } compactTrailing: {
                if !context.state.currentRoutineCompleted {
                    Text("\(context.state.currentSet)/\(context.state.totalSet)")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .padding(.trailing, 12)
                        .padding(.vertical, 7)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(.brand)
                        .padding(.trailing, 12)
                        .padding(.vertical, 7)
                }
            }
            // MARK: - minimal
            minimal: {
                if !context.state.currentRoutineCompleted {
                    if !context.state.isResting {
                        Image(systemName: "dumbbell")
                            .foregroundStyle(.brand)
                    } else {
                        Image(systemName: "timer")
                            .foregroundStyle(.brand)
                    }
                } else {
                    Image(systemName: "dumbbell.fill")
                        .foregroundStyle(.brand)
                }
            }
            .keylineTint(.brand)
        }
    }
}

// MARK: - WorkoutDataForLiveActivity -> ContentState
extension HowManySetWidgetAttributes.ContentState {
    /// WorkoutDataForLiveActivity를 HowManySetWidgetAttributes.ContentState로 변환
    init(from data: WorkoutDataForLiveActivity) {
        self.workoutTime = data.workoutTime
        self.isWorkingout = data.isWorkingout
        self.isWorkoutPaused = data.isWorkoutPaused
        self.exerciseName = data.exerciseName
        self.exerciseInfo = data.exerciseInfo
        self.currentRoutineCompleted = data.currentRoutineCompleted
        self.restStartDate = data.restStartDate
        // LiveActivity start 시에는 현재 홈의 휴식시간을 사용
        self.liveRestTime = data.restRemainingTimeInHome
        self.isResting = data.isResting
        self.isRestPaused = data.isRestPaused
        self.currentSet = data.currentSet
        self.totalSet = data.totalSet
        self.currentIndex = data.currentIndex
        self.workoutStartDate = data.workoutStartDate
    }

    func updateLiveActivityContentStates(from data: WorkoutDataForLiveActivity) -> Self {
        // 휴식 중이고 isRestPaused가 변경된 경우 기존 liveRestTime, restStartDate 유지
        // (Intent에서 이미 업데이트했으므로)
        let shouldPreserveRestData = self.isResting &&
        ((self.isRestPaused != data.isRestPaused)
         || (self.isWorkoutPaused != data.isWorkoutPaused))

        // 휴식이 새로 시작된 경우인지 확인 (이전에는 휴식 중이 아니었는데 지금 휴식 중인 경우)
        let isRestJustStarted = !self.isResting && data.isResting

        // liveRestTime 결정:
        // 1. Pause/Play 토글 시 -> 기존 값 유지
        // 2. 휴식이 새로 시작된 경우 -> restRemainingTimeInHome 사용
        // 3. 휴식 중인 경우 -> 기존 값 유지 (LiveActivity가 독립적으로 타이머 운영)
        // 4. 휴식 중이 아닌 경우 -> liveRestTime 사용 (다음 휴식을 위한 기본값)
        let newLiveRestTime: Float
        if shouldPreserveRestData {
            newLiveRestTime = self.liveRestTime
        } else if isRestJustStarted {
            newLiveRestTime = data.restRemainingTimeInHome
        } else if self.isResting && data.isResting {
            newLiveRestTime = self.liveRestTime
        } else {
            newLiveRestTime = data.liveRestTime
        }

        return HowManySetWidgetAttributes.ContentState(
            workoutTime: data.workoutTime,
            isWorkingout: data.isWorkingout,
            isWorkoutPaused: data.isWorkoutPaused,
            exerciseName: data.exerciseName,
            exerciseInfo: data.exerciseInfo,
            currentRoutineCompleted: data.currentRoutineCompleted,
            restStartDate: shouldPreserveRestData ? self.restStartDate : data.restStartDate,
            liveRestTime: newLiveRestTime,
            isResting: data.isResting,
            isRestPaused: data.isRestPaused,
            currentSet: data.currentSet,
            totalSet: data.totalSet,
            currentIndex: data.currentIndex,
            workoutStartDate: data.workoutStartDate
        )
    }
}

extension WorkoutDataForLiveActivity {
    /// 운동/휴식시간, Pause 상태 제외한 값들만 비교
    func isEqualExcludingTimer(to other: WorkoutDataForLiveActivity) -> Bool {
        return self.isWorkingout == other.isWorkingout &&
        self.exerciseName == other.exerciseName &&
        self.exerciseInfo == other.exerciseInfo &&
        self.currentRoutineCompleted == other.currentRoutineCompleted &&
        self.isResting == other.isResting &&
        self.currentSet == other.currentSet &&
        self.totalSet == other.totalSet &&
        self.currentIndex == other.currentIndex
    }
}
