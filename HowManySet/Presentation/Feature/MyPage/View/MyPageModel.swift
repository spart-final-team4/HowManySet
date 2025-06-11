//
//  MyPageModel.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import Foundation

struct MyPageCellModel {
    let title: String
    var version: String? = nil
}

struct MyPageSectionModel {
    let title: String
    let cellModel: [MyPageCellModel]
}

enum MyPageCollectionViewModel {
    static var model: [MyPageSectionModel] = [
        MyPageSectionModel(title: "앱 설정",
                           cellModel: [
                            MyPageCellModel(title: "알림 설정"),
                            MyPageCellModel(title: "언어 변경")
                           ]),
        MyPageSectionModel(title: "도움말 및 정보",
                           cellModel: [
                            MyPageCellModel(title: "버전 정보", version: "v1.0.0"),
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

enum MyPageCellType {
    case setNotification
    case setLanguage
    case showVersion
    case appReview
    case reportProblem
    case privacyPolicy
    case logout
    case deleteAccount
    case none
}

extension MyPageCellType {
    init(indexPath: IndexPath) {
        switch indexPath {
        case [0,0]:
            self = .setNotification
        case [0,1]:
            self = .setLanguage
        case [1,0]:
            self = .showVersion
        case [1,1]:
            self = .appReview
        case [1,2]:
            self = .reportProblem
        case [2,0]:
            self = .privacyPolicy
        case [2,1]:
            self = .logout
        case [2,2]:
            self = .deleteAccount
        default:
            self = .none
        }
    }
}
