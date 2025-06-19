//
//  EditRoutineTableModel.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import Foundation
import RxDataSources

/// 운동 루틴 편집을 위한 셀 모델
struct EditRoutioneCellModel {
    let id = UUID().uuidString
    let name: String           // 운동 이름
    let setText: String        // 세트 수 정보
    let weightText: String     // 최대 중량 정보
    let repsText: String       // 최대 반복 수 정보
}

/// RxDataSources 섹션 모델 정의
struct EditRoutineSection {
    var headerTitle: String                    // 섹션 헤더 타이틀 (루틴 이름)
    var items: [Item]                          // 셀 데이터 배열
}

extension EditRoutineSection: SectionModelType {
    typealias Item = EditRoutioneCellModel

    init(original: EditRoutineSection, items: [EditRoutioneCellModel]) {
        self = original
        self.items = items
    }
}

// 래핑 클래스
final class EditRoutineDragItem: NSObject {
    let model: EditRoutioneCellModel
    init(model: EditRoutioneCellModel) {
        self.model = model
    }
}
