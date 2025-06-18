//
//  SetProgressBar.swift
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
                RoundedRectangle(cornerRadius: 5)
                    .fill(index < currentSet ? Color.brand : Color.gray)
                    .frame(height: 12)
            }
        }
        .padding(.horizontal, 4)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
