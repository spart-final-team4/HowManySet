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
    
    var body: some View {
        TabView(selection: $selection) {
            RoutineInfoView(routine: WorkoutRoutine.mockData[0]).tag(Tab.routineInfo)
            WorkoutView().tag(Tab.workout)
            RestSettingView().tag(Tab.restSetting)
        }
    }
}

#Preview {
    SessionPagingView()
}
