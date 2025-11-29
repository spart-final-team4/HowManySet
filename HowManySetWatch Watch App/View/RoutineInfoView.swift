//
//  RoutineInfoView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/29/25.
//

import SwiftUI

struct RoutineInfoView: View {
    
    private let pretendard = Pretendard()
    @State var routine: WorkoutRoutine
    
    var body: some View {
        List {
            ForEach(routine.workouts) { workout in
                HStack {
                    Text(workout.name)
                        .font(.custom(pretendard.pretendardRegular, size: 12))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(workout.sets.count)set")
                        .font(.custom(pretendard.pretendardRegular, size: 12))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 2)
            }
        }
        .listStyle(.carousel)
        .navigationTitle(routine.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        RoutineInfoView(routine: WorkoutRoutine.mockData[0])
    }
}
