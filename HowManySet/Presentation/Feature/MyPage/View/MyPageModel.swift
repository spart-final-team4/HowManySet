//
//  MyPageModel.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import Foundation

/// 마이페이지에서 사용할 셀 모델 구조체
/// - 셀의 제목과 선택적으로 버전 정보를 포함
struct MyPageCellModel {
    /// 셀의 표시 제목
    let title: String
    /// 버전 정보 (필요한 경우에만 사용)
    var version: String? = nil
}

/// 마이페이지 섹션 모델 구조체
/// - 섹션의 제목과 해당 섹션에 포함된 셀 모델 리스트를 포함
struct MyPageSectionModel {
    /// 섹션 제목
    let title: String
    /// 섹션에 포함된 셀 모델 배열
    let cellModel: [MyPageCellModel]
}

/// 마이페이지 전체 데이터 모델을 구성하는 열거형
/// - static 배열 형태로 섹션 데이터를 정적으로 정의
enum MyPageCollectionViewModel {
    /// 마이페이지에 표시할 섹션과 셀 구성 데이터
    static var model: [MyPageSectionModel] = [
        MyPageSectionModel(title: String(localized: "앱 설정"),
                           cellModel: [
                            MyPageCellModel(title: String(localized: "알림 설정")),
                            MyPageCellModel(title: String(localized: "언어 변경"))
                           ]),
        MyPageSectionModel(title: String(localized: "도움말 및 정보"),
                           cellModel: [
                            MyPageCellModel(title: String(localized: "버전 정보"), version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String),
                            MyPageCellModel(title: String(localized: "라이센스 정보")),
                            MyPageCellModel(title: String(localized: "앱 평가")),
                            MyPageCellModel(title: String(localized: "문제 제보하기"))
                           ]),
        MyPageSectionModel(title: String(localized: "계정"),
                           cellModel: [
                            MyPageCellModel(title: String(localized: "개인정보 처리 방침")),
                            MyPageCellModel(title: String(localized: "로그아웃")),
                            MyPageCellModel(title: String(localized: "계정 삭제"))
                           ])
    ]
}

/// 마이페이지 셀 타입을 명시적으로 정의한 열거형
/// - IndexPath에 따라 각 셀의 기능을 구분하기 위해 사용
enum MyPageCellType {
    case setNotification        // 알림 설정
    case setLanguage            // 언어 변경
    case showVersion            // 버전 정보 표시
    case showLicense            // 오픈소스 라이센스 표시
    case appReview              // 앱 평가
    case reportProblem          // 문제 제보
    case privacyPolicy          // 개인정보 처리방침
    case logout                 // 로그아웃
    case deleteAccount          // 계정 삭제
    case none                   // 일치하지 않는 경우
}

extension MyPageCellType {
    
    /// IndexPath를 기반으로 해당하는 셀 타입을 초기화
    /// - Parameters:
    ///   - indexPath: 선택된 셀의 위치
    init(indexPath: IndexPath) {
        switch indexPath {
        case [0,0]:
            self = .setNotification
        case [0,1]:
            self = .setLanguage
        case [1,0]:
            self = .showVersion
        case [1,1]:
            self = .showLicense
        case [1,2]:
            self = .appReview
        case [1,3]:
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
