//
//  NotificationService.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UserNotifications

final class NotificationService {
    
    static let shared = NotificationService()
    
    private init() {}
    
    func requestNotification() { UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("알림 권한 granted: \(granted)")
        }
    }
    
    func scheduleRestFinishedNotification(seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "휴식 종료!")
        content.body = String(localized: "이제 다음 세트를 시작하세요!")
        content.sound = .default

        let trigeer = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "restFinished", content: content, trigger: trigeer)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 예약 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func removeRestNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["restFinished"])
        print("알림 예약 제거")
    }
}
