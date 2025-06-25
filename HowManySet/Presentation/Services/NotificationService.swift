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
    
    func sendRestFinishedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "휴식 종료!"
        content.body = "이제 다음 세트를 시작하세요!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "restFinished", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
