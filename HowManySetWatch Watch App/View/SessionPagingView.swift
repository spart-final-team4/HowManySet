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
    
    @State var routine: WorkoutRoutine
    @State var isResting = false
    
    @State private var workoutPageIndex: Int = 1
    @State private var restPageIndex: RestTabs = .rest
    
    @State private var restStartDate: Date? = Date.now

    var body: some View {
        if !isResting {
            TabView(selection: $workoutPageIndex) {
                RoutineInfoView(routine: routine).tag(0)
                
                ForEach(Array(routine.workouts.enumerated()), id: \.element.id) { index, workout in
                    WorkoutView(workout: workout, isResting: $isResting, restStartDate: $restStartDate).tag(index+1)
                }
            }
            .tabViewStyle(.page)
        } else {
            TabView(selection: $restPageIndex) {
                RoutineInfoView(routine: routine).tag(RestTabs.routineInfo)
                
                RestView(restStartDate: $restStartDate, isResting: $isResting).tag(RestTabs.rest)
                
                RestSettingView().tag(RestTabs.restSetting)
            }
            .tabViewStyle(.page)
        }
    }
}

#Preview {
    SessionPagingView(routine: WorkoutRoutine.mockData[0], isResting: false)
}
