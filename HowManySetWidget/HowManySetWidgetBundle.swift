//
//  HowManySetLiveActivityBundle.swift
//  HowManySetLiveActivity
//
//  Created by 정근호 on 5/30/25.
//

import WidgetKit
import SwiftUI

@main
struct HowManySetLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        HowManySetWidget()
        HowManySetWidgetControl()
        HowManySetWidgetLiveActivity()
    }
}
