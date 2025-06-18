//
//  SetProgressBarForLiveActivity.swift
//  HowManySet
//
//  Created by 정근호 on 6/19/25.
//

import SwiftUI

struct SetProgressBarForLiveActivity: View {
    let totalSets: Int
    let currentSet: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<totalSets, id: \.self) { index in
                Rectangle()
                    .fill(index < currentSet ? Color.brand : Color.gray)
                    .frame(height: 12)
            }
            .background(Color("Background"))
        }
        .cornerRadius(4)
        .background(Color("Background"))
    }
}
