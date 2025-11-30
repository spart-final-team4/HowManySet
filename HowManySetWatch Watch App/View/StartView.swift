//
//  StartView.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/26/25.
//

import SwiftUI

struct StartView: View {
   
    var body: some View {
        
        @State var routine = WorkoutRoutine.mockData[0]
        
        NavigationView {
            SessionPagingView(routine: routine)
        }
    }
}

#Preview {
    StartView()
}
