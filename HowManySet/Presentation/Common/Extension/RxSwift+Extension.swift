//
//  RxSwift+Extension.swift
//  HowManySet
//
//  Created by GO on 6/30/25.
//

import RxSwift

/// 타임아웃 처리
extension ObservableType {
    func timeoutWithDefault<T>(_ dueTime: RxTimeInterval, scheduler: SchedulerType, defaultValue: T) -> Observable<T> where Element == T {
        return self.timeout(dueTime, scheduler: scheduler)
            .catchAndReturn(defaultValue)
    }
}
