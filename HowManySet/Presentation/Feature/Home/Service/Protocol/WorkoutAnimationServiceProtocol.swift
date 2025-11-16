//
//  WorkoutAnimationServiceProtocol.swift
//  HowManySet
//
//  Created by 정근호 on 2025-11-16.
//

import Foundation

/// 운동 애니메이션 서비스 프로토콜
protocol WorkoutAnimationServiceProtocol {
    /// 프로그레스바 완료 애니메이션
    /// - Parameters:
    ///   - cardView: 애니메이션할 카드뷰
    ///   - progress: 프로그레스 값
    ///   - completion: 완료 콜백
    func animateProgressBarCompletion(
        _ cardView: HomePagingCardView,
        with progress: Int,
        completion: @escaping () -> Void
    )

    /// 카드 삭제 애니메이션
    /// - Parameters:
    ///   - cardView: 삭제할 카드뷰
    ///   - completion: 완료 콜백
    func animateCardDeletion(
        _ cardView: HomePagingCardView,
        completion: @escaping () -> Void
    )
}
