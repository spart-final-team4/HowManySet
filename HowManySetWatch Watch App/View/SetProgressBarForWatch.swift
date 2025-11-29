//
//  SetProgressBarForWatch.swift
//  HowManySetWatch Watch App
//
//  Created by 정근호 on 11/26/25.
//

import SwiftUI

struct SetProgressBarForWatch: View {
    let totalSets: Int
    let currentSet: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<totalSets, id: \.self) { index in
                Rectangle()
                    .fill(index < currentSet ? Color.green6 : Color.gray)
                    .frame(height: 12)
            }
            .background(Color("Background"))
        }
        .cornerRadius(4)
        .background(Color("Background"))
    }
}
