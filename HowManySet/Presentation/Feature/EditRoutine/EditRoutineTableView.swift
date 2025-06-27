//
//  EditRoutineTableView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// 운동 루틴 목록을 표시하고 편집할 수 있는 커스텀 테이블 뷰
final class EditRoutineTableView: UITableView {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private(set) var cellMoreButtonTapped = PublishRelay<IndexPath>()
    private(set) var footerViewTapped = PublishRelay<Void>()
    private(set) var dragDropRelay = PublishRelay<(source: IndexPath, destination: IndexPath)>()
    
    private var caller: ViewCaller
    
    /// RxDataSources를 위한 DataSource 타입 별칭
    typealias DataSource = RxTableViewSectionedReloadDataSource<EditRoutineSection>

    /// 외부에서 바인딩 가능하도록 노출된 RxDataSource
    var rxDataSource: DataSource?

    // MARK: - Initializer
    init(frame: CGRect, style: UITableView.Style, caller: ViewCaller) {
        self.caller = caller
        super.init(frame: frame, style: style)
        delegate = self
        // TODO: 마이너 패치때 도입
//        dragInteractionEnabled = true
//        dragDelegate = self
//        dropDelegate = self
        bind()
        backgroundColor = .background
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Binding
    /// RxDataSource 바인딩 설정 및 셀 구성 정의
    func bind() {
        rxDataSource = DataSource(
            configureCell: { (dataSource, tableView, indexPath, item) in
                
                // 셀, 헤더, 푸터 등록
                tableView.register(EditRoutineTableHeaderView.self,
                                   forHeaderFooterViewReuseIdentifier: EditRoutineTableHeaderView.identifier)
                tableView.register(EditRoutineTableFooterView.self,
                                   forHeaderFooterViewReuseIdentifier: EditRoutineTableFooterView.identifier)
                tableView.register(EditRoutineTableViewCell.self,
                                   forCellReuseIdentifier: EditRoutineTableViewCell.identifier)
                
                // 셀 구성
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: EditRoutineTableViewCell.identifier,
                    for: indexPath
                ) as? EditRoutineTableViewCell else {
                    return UITableViewCell()
                }
                
                
                cell.configure(indexPath: indexPath,
                               model: item,
                               caller: self.caller)
                cell.bind(indexPath: indexPath,
                          relay: self.cellMoreButtonTapped)
                cell.selectionStyle = .none
                return cell
            })
        rxDataSource?.canMoveRowAtIndexPath = { _, _ in return true }
    }

    // MARK: - Public Method
    /// WorkoutRoutine 데이터를 기반으로 테이블 뷰에 바인딩
    func apply(routine: WorkoutRoutine) {
        var items = [EditRoutioneCellModel]()

        routine.workouts.forEach { workout in
            items.append(mappingRoutineToCellModel(workout: workout))
        }

        let model = [EditRoutineSection(headerTitle: routine.name, items: items)]

        guard let rxDataSource = rxDataSource else { return }
        dataSource = nil
        Observable.just(model)
            .bind(to: self.rx.items(dataSource: rxDataSource))
            .disposed(by: disposeBag)
    }
    
    func mappingRoutineToCellModel(workout: Workout) -> EditRoutioneCellModel {
        return EditRoutioneCellModel(name: workout.name,
                                     setText: "총 \(workout.sets.count)세트",
                                     weightText: "\(workout.sets.map { $0.weight }.max()!)\(workout.sets[0].unit)",
                                     repsText: "\(workout.sets.map { $0.reps }.max()!)회")
    }
}

// MARK: - UITableViewDelegate
extension EditRoutineTableView: UITableViewDelegate {

    /// 섹션 헤더 뷰 구성
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionModel = rxDataSource?.sectionModels[section],
              let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: EditRoutineTableHeaderView.identifier
              ) as? EditRoutineTableHeaderView else {
            return nil
        }
        headerView.configure(with: sectionModel.headerTitle)
        return headerView
    }

    /// 섹션 푸터 뷰 구성 (ex: + 운동 추가 버튼 등)
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: EditRoutineTableFooterView.identifier
        ) as? EditRoutineTableFooterView else {
            return nil
        }
        
        footerView.plusExcerciseButtonTapped
            .bind(to: footerViewTapped)
            .disposed(by: footerView.disposeBag)
        
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}


extension EditRoutineTableView: UITableViewDragDelegate {
    func tableView(
        _ tableView: UITableView,
        itemsForBeginning session: any UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem]  {
        session.localContext = indexPath
        guard let item = rxDataSource?[indexPath] else {
            return []
        }
        print(item)
        // 실제 데이터 전달
        let itemProvider = NSItemProvider(object: item.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item // Drop 시 직접 사용 가능
        return [dragItem]
    }
    
}
extension EditRoutineTableView: UITableViewDropDelegate {
    func tableView(
        _ tableView: UITableView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UITableViewDropProposal {
        guard
            let sourceIndexPath = session.localDragSession?.localContext as? IndexPath,
            let destinationIndexPath = destinationIndexPath,
            sourceIndexPath != destinationIndexPath
        else {
            return UITableViewDropProposal(operation: .cancel)
        }
        dragDropRelay.accept((source: sourceIndexPath, destination: destinationIndexPath))
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        performDropWith coordinator: UITableViewDropCoordinator
    ) {
        guard
            let sourceIndexPath = coordinator.items.first?.sourceIndexPath,
            let destinationIndexPath = coordinator.destinationIndexPath
        else { return }
        dragDropRelay.accept((source: sourceIndexPath, destination: destinationIndexPath))
    }
    
}
