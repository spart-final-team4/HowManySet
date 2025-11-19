//
//  LiveActivitySyncService.swift
//  HowManySet
//
//  Created by 정근호 on 11/16/25.
//

import Foundation

/// LiveActivity 동기화
final class LiveActivitySyncService: LiveActivitySyncServiceProtocol {
    
    private var syncTimer: Timer?
    private var actionHandler: ((LiveActivityAction) -> Void)?

    init() {}

    func startSync(actionHandler: @escaping (LiveActivityAction) -> Void) {
        // 이미 타이머가 실행 중이면 중복 실행 방지
        guard syncTimer == nil else { return }

        self.actionHandler = actionHandler

        // 0.5초마다 LiveActivity 이벤트 체크
        syncTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(syncWithLiveActivity), userInfo: nil, repeats: true)
    }
    
    func stopSync() {
        syncTimer?.invalidate()
        syncTimer = nil
        actionHandler = nil
    }
    
    /// LiveActivity 버튼 클릭 이벤트 감지
    @objc private func syncWithLiveActivity() {
        guard let handler = actionHandler else { return }

        // 휴식 일시정지/재생 버튼 이벤트
        LiveActivityAppGroupEventBridge.shared.checkPlayAndPauseRestEvent { _ in
            handler(.restPauseButtonClicked)
        }

        // 세트 완료 버튼 이벤트
        LiveActivityAppGroupEventBridge.shared.checkSetCompleteEvent { index in
            handler(.setCompleteButtonClicked(at: index))
        }

        // 휴식 스킵 버튼 이벤트
        LiveActivityAppGroupEventBridge.shared.checkSkipRestEvent { index in
            handler(.skipRestButtonClicked(at: index))
        }
    }

    deinit {
        stopSync()
    }
}
