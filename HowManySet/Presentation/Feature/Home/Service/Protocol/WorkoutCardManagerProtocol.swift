//
//  WorkoutCardManagerProtocol.swift
//  HowManySet
//
//  Created by 정근호 on 2025-11-16.
//

import Foundation

/// 운동 카드뷰 관리 서비스 프로토콜
protocol WorkoutCardManagerProtocol {
    /// 운동 카드뷰 컨테이너
    var pagingCardViewContainer: [HomePagingCardView] { get set }

    /// 현재 페이지 인덱스
    var currentPage: Int { get set }

    /// 이전 페이지 인덱스
    var previousPage: Int { get set }

    /// 운동 카드뷰들 초기 생성 및 레이아웃 설정
    /// - Parameters:
    ///   - cardStates: 운동 카드 상태 배열
    ///   - homeView: 홈 뷰
    func configureExerciseCardViews(
        cardStates: [WorkoutCardState],
        in homeView: HomeView
    )

    /// 카드 삭제 시 레이아웃 재조정
    /// - Parameters:
    ///   - newPage: 새로운 페이지 인덱스
    ///   - homeView: 홈 뷰
    func setExerciseCardViewsLayout(
        newPage: Int,
        in homeView: HomeView
    )

    /// 현재 페이지에서 보이는 카드의 실제 exerciseIndex 반환
    /// - Returns: 현재 보이는 운동 인덱스
    func getCurrentVisibleExerciseIndex() -> Int

    /// 페이지 변경 애니메이션
    /// - Parameters:
    ///   - newCurrentPage: 새로운 페이지 인덱스
    ///   - homeView: 홈 뷰
    func handlePageChanged(
        newCurrentPage: Int,
        in homeView: HomeView
    )
}
