//
//  SetProgressBarWrapper.swift
//  HowManySet
//
//  Created by 정근호 on 6/7/25.
//

import SwiftUI

struct SetProgressBarRepresentable: UIViewRepresentable {
    var totalSets: Int
    var currentSet: Int

    func makeUIView(context: Context) -> SetProgressBarView {
        let view = SetProgressBarView()
        view.setProgress(totalSets: totalSets, currentSet: currentSet)
        return view
    }

    func updateUIView(_ view: SetProgressBarView, context: Context) {
        view.setProgress(totalSets: totalSets, currentSet: currentSet)
    }
}
