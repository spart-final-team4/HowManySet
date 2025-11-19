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
    private(set) var dragDropRelay = PublishRelay<(source: IndexPath, destination: IndexPath)>()
    private(set) var addExerciseButtonTapped = PublishRelay<Void>()
    private let itemsRelay = BehaviorRelay<[EditRoutineSection]>(value: [])
    
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
        self.setEditing(true, animated: false)
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
                cell.selectionStyle = .none
                
                let longPressGesture = UILongPressGestureRecognizer()
                longPressGesture.rx.event
                    .compactMap{ $0 }
                    .filter{ $0.state == .began }
                    .filter{ gesture in
                        let location = gesture.location(in: cell)
                        if cell.contentView.frame.contains(location) { return true }
                        return false
                    }
                    .subscribe(onNext: { [weak self] _ in
                        self?.cellMoreButtonTapped.accept(indexPath)
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.addGestureRecognizer(longPressGesture)
                return cell
            })
        guard let rxDataSource else { return }
        
        itemsRelay
            .bind(to: rx.items(dataSource: rxDataSource))
            .disposed(by: disposeBag)
        
    }

    // MARK: - Public Method
    /// WorkoutRoutine 데이터를 기반으로 테이블 뷰에 바인딩
    func apply(routine: WorkoutRoutine) {
        var items = [EditRoutioneCellModel]()

        routine.workouts.forEach { workout in
            items.append(mappingRoutineToCellModel(workout: workout))
        }

        let model = [EditRoutineSection(headerTitle: routine.name, items: items)]
        itemsRelay.accept(model)
    }
    
    func mappingRoutineToCellModel(workout: Workout) -> EditRoutioneCellModel {
        return EditRoutioneCellModel(
            name: workout.name,
            setText: String(format: String(localized: "총 %d세트"), workout.sets.count),
            weightText: "\(workout.sets.map { $0.weight }.max()!.clean)\(workout.sets[0].unit)",
            repsText: String(format: String(localized: "%d회"), workout.sets.map { $0.reps }.max()!)
        )
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
        
        headerView.plusExerciseButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.addExerciseButtonTapped.accept(())
            })
            .disposed(by: disposeBag)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView,
                   shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
