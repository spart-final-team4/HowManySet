//
//  StartView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/26/25.
//

import SwiftUI

// 네비게이션 경로에 넣을 라우트 식별자
enum Route: Hashable {
    case workoutComplete
}

struct StartView: View {
    @State private var routineList = WorkoutRoutine.mockData
    @State private var currentPage: Int = 0
    @State private var path = NavigationPath()
    
    private let pretendard = Pretendard()
    private let todayExerciseText = "오늘 운동"
    
    private var todayTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월d일"
        return f.string(from: Date())
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading) {
                
                Text(todayTitle)
                    .font(.custom(pretendard.pretendardSemiBold, size: 20))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(Array(routineList.enumerated()), id: \.offset) { index, routine in
                        NavigationLink {
                            // path를 RoutineInfoView로 전달
                            RoutineInfoView(routine: routine, showStartsButton: true, path: $path)
                        } label: {
                            RoutineCardView(
                                routine: routine,
                                isActive: currentPage == index
                            )
                        }
                        .buttonStyle(.plain)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
            }
            .navigationTitle(todayExerciseText)
            // Route 타입을 경로에 append했을 때 목적지 매핑
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .workoutComplete:
                    WorkoutCompleteView(path: $path)
                }
            }
        }
    }
}

/// TabView의 각 페이지에 들어갈 카드 뷰
struct RoutineCardView: View {
    let routine: WorkoutRoutine
    var isActive: Bool = false
    private let pretendard = Pretendard()
    private let exerciseCountText = "개의 운동"
    
    var body: some View {
        HStack(alignment: .center) {
            Text(routine.name)
                .font(.custom(pretendard.pretendardRegular, size: 12))
                .foregroundColor(.background)
            
            Spacer()
            
            Text("\(routine.workouts.count)\(exerciseCountText)")
                .font(.custom(pretendard.pretendardRegular, size: 12))
                .foregroundColor(.background)
        }
        .frame(height: 80)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(isActive ? .green6 : .disabledButton)
        .cornerRadius(12)
    }
}

#Preview {
    StartView()
}
