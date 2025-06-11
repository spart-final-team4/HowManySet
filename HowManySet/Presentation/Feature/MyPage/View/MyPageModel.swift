//
//  MyPageModel.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import Foundation

struct MyPageCellModel {
    let title: String
}

struct MyPageSectionModel {
    let title: String
    let cellModel: [MyPageCellModel]
}

enum MyPageCollectionViewModel {
    static let model: [MyPageSectionModel] = [
        MyPageSectionModel(title: "앱 설정",
                           cellModel: [
                            MyPageCellModel(title: "무게 단위 설정"),
                            MyPageCellModel(title: "알림 설정"),
                            MyPageCellModel(title: "언어 변경")
                           ]),
        MyPageSectionModel(title: "도움말 및 정보",
                           cellModel: [
                            MyPageCellModel(title: "버전 정보"),
                            MyPageCellModel(title: "앱 평가"),
                            MyPageCellModel(title: "문제 제보하기")
                           ]),
        MyPageSectionModel(title: "계정",
                           cellModel: [
                            MyPageCellModel(title: "개인정보 처리 방침"),
                            MyPageCellModel(title: "로그아웃"),
                            MyPageCellModel(title: "계정 삭제")
                           ])
    ]
}
