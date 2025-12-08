//
//  SessionPagingView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/29/25.
//

import SwiftUI
import WatchKit

enum RestTabs {
    case routineInfo, rest, restSetting
}

struct SessionPagingView: View {
    
    // MARK: - Properties
    @State var routine: WorkoutRoutine
    
    @State private var workoutPageIndex: Int = 1
    @State private var workoutStartDate: Date = Date.now
    
    @State private var restPageIndex: RestTabs = .rest
    @State private var isResting = false
    @State private var isRestPaused = false
    /// 전체 운동의 현재 세트 수 딕셔너리 [운동ID: 현재 세트]
    @State private var currentSets: [String: Int] = [:]
    /// 설정된 휴식 시간
    @State private var restDuration: TimeInterval = 60
    /// 남은 휴식 시간
    @State private var remainingRestTime: TimeInterval = 60
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var path: Binding<NavigationPath>

    // MARK: - Body
    var body: some View {
        VStack {
            if !isResting {
                workoutTabView
            } else {
                restTabView
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear(perform: setupView)
        .onReceive(timer, perform: onTimerTick)
        .onChange(of: isResting, perform: onRestingChange)
    }
}

// MARK: - Views
extension SessionPagingView {
    private var workoutTabView: some View {
        TabView(selection: $workoutPageIndex) {
            
            NowPlayingView()
                .toolbar(.hidden, for: .navigationBar)
            
            RoutineInfoView(routine: routine, showStartsButton: false, path: path).tag(0)
            
            ForEach(Array(routine.workouts.enumerated()), id: \.element.id) { index, workout in
                // 각 WorkoutView에 대한 커스텀 바인딩 생성
                let currentSetBinding = Binding<Int>(
                    get: { self.currentSets[workout.id] ?? 0 },
                    set: { self.currentSets[workout.id] = $0 }
                )
                
                WorkoutView(
                    workout: workout,
                    workoutStartDate: workoutStartDate,
                    currentSet: currentSetBinding,
                    isResting: $isResting,
                    onWorkoutComplete: { completedWorkoutId in
                        handleWorkoutComplete(completedWorkoutId: completedWorkoutId)
                    }
                )
                .tag(index + 1)
            }
        }
        .tabViewStyle(.page)
    }
    
    private var restTabView: some View {
        TabView(selection: $restPageIndex) {
            
            NowPlayingView()
                .toolbar(.hidden, for: .navigationBar)
            
            RoutineInfoView(routine: routine, showStartsButton: false, path: path).tag(RestTabs.routineInfo)
            
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
        // 운동 시간 설정
        workoutStartDate = Date.now
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
    
    // 운동 완료 시 호출
    private func handleWorkoutComplete(completedWorkoutId: String) {
        // 해당 운동을 루틴에서 제거
        if let index = routine.workouts.firstIndex(where: { $0.id == completedWorkoutId }) {
            routine.workouts.remove(at: index)
            
            if workoutPageIndex > index + 1 { // 제거된 운동보다 뒤에 있는 경우
                workoutPageIndex -= 1
            } else if workoutPageIndex == index + 1 { // 제거된 운동이 현재 표시 중인 경우
                if routine.workouts.isEmpty {
                    workoutPageIndex = 0 // 모든 운동 완료 시
                } else {
                    // 다음 운동으로 자동으로 넘어가지 않고, 현재 인덱스가 다음 운동을 가리키도록 (
                    workoutPageIndex = min(workoutPageIndex, routine.workouts.count)
                }
            }
        }
        
        // 모든 운동이 완료되었는지 확인
        if routine.workouts.isEmpty {
            path.wrappedValue.append(Route.workoutComplete)
        }
    }
}


#Preview {
    SessionPagingView(routine: WorkoutRoutine.mockData[0], path: .constant(NavigationPath()))
}
