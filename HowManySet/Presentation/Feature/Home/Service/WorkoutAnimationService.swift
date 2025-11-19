//
//  WorkoutAnimationService.swift
//  HowManySet
//
//  Created by 정근호 on 2025-11-16.
//

import UIKit

/// 운동 중 홈 뷰 애니메이션 서비스
final class WorkoutAnimationService: WorkoutAnimationServiceProtocol {

    init() {}

    /// 프로그레스바 완료 애니메이션
    func animateProgressBarCompletion(
        _ cardView: HomePagingCardView,
        with progress: Int,
        completion: @escaping () -> Void
    ) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                // 프로그레스바를 100%로
                cardView.setProgressBar.updateProgress(currentSet: progress)
            },
            completion: { _ in
                completion()
            }
        )
    }

    /// 카드 삭제 애니메이션
    func animateCardDeletion(
        _ cardView: HomePagingCardView,
        completion: @escaping () -> Void
    ) {
        // 카드가 위로 사라지면서 페이드아웃
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                cardView.transform = CGAffineTransform(translationX: 0, y: -cardView.frame.height)
                    .scaledBy(x: 0.8, y: 0.8)
                cardView.alpha = 0.1
            },
            completion: { _ in
                cardView.isHidden = true
                cardView.transform = .identity
                cardView.alpha = 1
                completion()
            }
        )
    }
}
