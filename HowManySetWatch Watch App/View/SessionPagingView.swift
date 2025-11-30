//
//  SessionPagingView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/29/25.
//

import SwiftUI

enum Tab {
    case routineInfo
    case workout
    case restSetting
}

struct SessionPagingView: View {
    
    @State private var selection: Tab = .workout
    @State private var isResting = false
    @State var routine: WorkoutRoutine
    
    var body: some View {
        TabView(selection: $selection) {
            if !isResting {
                RoutineInfoView(routine: WorkoutRoutine.mockData[0]).tag(Tab.routineInfo)
                ForEach(routine.workouts) { workout in
                    WorkoutView(workout: workout).tag(Tab.workout)
                }
            } else {
                RoutineInfoView(routine: WorkoutRoutine.mockData[0]).tag(Tab.routineInfo)
                RestView()
                RestSettingView()
            }
        }
    }
}

#Preview {
    SessionPagingView(routine: WorkoutRoutine.mockData[0])
}
