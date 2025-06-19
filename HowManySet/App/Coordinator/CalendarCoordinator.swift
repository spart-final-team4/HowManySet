//
//  CalendarViewCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol CalendarCoordinatorProtocol: Coordinator {
    func presentRecordDetailView(record: WorkoutRecord)
}

/// 캘린더 흐름 담당 coordinator
/// 시작 시 calendar 화면 push
final class CalendarCoordinator: CalendarCoordinatorProtocol {
    
    /// 캘린더 흐름용 navigation controller
    private let navigationController: UINavigationController

    /// 의존성 주입 컨테이너
    private let container: DIContainer

    /// coordinator 생성자
    /// - Parameters:
    ///   - navigationController: 캘린더 흐름 navigation
    ///   - container: DI 컨테이너
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    /// 캘린더 흐름 시작
    func start() {
        let calendarVC = container.makeCalendarViewController(coordinator: self)
        navigationController.pushViewController(calendarVC, animated: true)
    }

    /// 기록 상세 화면 모달 present
    /// large sheet 스타일 + grabber 표시
    func presentRecordDetailView(record: WorkoutRecord) {
        let realmService: RealmServiceProtocol = RealmService()
        let recordRepository = RecordRepositoryImpl(realmService: realmService)
        let saveRecordUseCase = SaveRecordUseCase(repository: recordRepository)
        let fetchRecordUseCase = FetchRecordUseCase(repository: recordRepository)

        let reactor = RecordDetailViewReactor(saveRecordUseCase: saveRecordUseCase, fetchRecordUseCase: fetchRecordUseCase,
                                              record: record)
        let recordDetailVC = RecordDetailViewController(reactor: reactor)
        
        if let sheet = recordDetailVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        navigationController.present(recordDetailVC, animated: true)
    }
}
