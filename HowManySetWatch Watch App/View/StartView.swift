//
//  StartView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/26/25.
//

import SwiftUI

struct StartView: View {
   
    var body: some View {
        WorkoutView(workout: Workout.mockData[0])
            .scenePadding()
    }
}

#Preview {
    StartView()
}
