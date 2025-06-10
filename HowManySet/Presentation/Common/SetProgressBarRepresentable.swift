//
//  SetProgressBarWrapper.swift
//  HowManySet
//
//  Created by 정근호 on 6/7/25.
//

import SwiftUI

struct SetProgressBarRepresentable: UIViewRepresentable {
    var totalSets: Int = 5
    var currentSet: Int = 2

    func makeUIView(context: Context) -> SetProgressBarView {
        let view = SetProgressBarView()
        view.setupSegments(totalSets: totalSets)
        return view
    }

    func updateUIView(_ view: SetProgressBarView, context: Context) {
        view.updateProgress(currentSet: currentSet)
    }
}

struct SetProgressBarPreview_Previews: PreviewProvider {
    static var previews: some View {
        SetProgressBarRepresentable(totalSets: 5, currentSet: 2)
            .frame(height: 10)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
