//
//  SessionPagingView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/29/25.
//

import SwiftUI

enum RestTabs {
    case routineInfo, rest, restSetting
}

struct SessionPagingView: View {
    
    // MARK: - Properties
    @State var routine: WorkoutRoutine
    
    // Tab
    @State private var workoutPageIndex: Int = 1
    @State private var restPageIndex: RestTabs = .rest
    
    // State
    @State private var isResting = false
    @State private var isRestPaused = false
    
    /// 전체 운동의 현재 세트 수 딕셔너리 [운동ID: 현재 세트]
    @State private var currentSets: [String: Int] = [:]
    
    /// 설정된 휴식 시간
    @State private var restDuration: TimeInterval = 60
    /// 남은 휴식 시간
    @State private var remainingRestTime: TimeInterval = 60
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Body
    var body: some View {
        VStack {
            if !isResting {
                workoutTabView
            } else {
                restTabView
            }
        }
        .onAppear(perform: setupView)
        .onReceive(timer, perform: onTimerTick)
        .onChange(of: isResting, perform: onRestingChange)
    }
}

// MARK: - Views
extension SessionPagingView {
    /// 운동 중 View
    private var workoutTabView: some View {
        TabView(selection: $workoutPageIndex) {
            RoutineInfoView(routine: routine, showStartsButton: false).tag(0)
            
            ForEach(Array(routine.workouts.enumerated()), id: \.element.id) { index, workout in
                // 각 WorkoutView에 대한 커스텀 바인딩 생성
                let currentSetBinding = Binding<Int>(
                    get: { self.currentSets[workout.id] ?? 0 },
                    set: { self.currentSets[workout.id] = $0 }
                )
                
                WorkoutView(
                    workout: workout,
                    currentSet: currentSetBinding,
                    isResting: $isResting
                )
                .tag(index + 1)
            }
        }
        .tabViewStyle(.page)
    }
    
    
    private var restTabView: some View {
        TabView(selection: $restPageIndex) {
            RoutineInfoView(routine: routine, showStartsButton: false).tag(RestTabs.routineInfo)
            
            RestView(
                remainingTime: $remainingRestTime,
                isResting: $isResting,
                isPaused: $isRestPaused
            )
            .tag(RestTabs.rest)
            
            RestSettingView(restTime: $restDuration)
                .tag(RestTabs.restSetting)
        }
        .tabViewStyle(.page)
    }
}

// MARK: - Methods
extension SessionPagingView {
    private func setupView() {
        // 운동 세트 딕셔너리 초기화
        currentSets = routine.workouts.reduce(into: [String: Int]()) { dict, workout in
            dict[workout.id] = 0
        }
        // 남은 휴식 시간 초기화
        remainingRestTime = restDuration
    }
    
    private func onTimerTick(_ : Date) {
        guard isResting, !isRestPaused else { return }
        
        if remainingRestTime > 0 {
            remainingRestTime -= 1
        } else {
            isResting = false
        }
    }
    
    private func onRestingChange(to isNowResting: Bool) {
        if isNowResting {
            // 휴식 시작 시, 남은 시간을 설정된 휴식 시간으로 초기화
            remainingRestTime = restDuration
            // 휴식 탭으로 전환
            restPageIndex = .rest
        } else {
            // 휴식이 끝나면 일시정지 상태 해제
            isRestPaused = false
        }
    }
}


#Preview {
    SessionPagingView(routine: WorkoutRoutine.mockData[0])
}
