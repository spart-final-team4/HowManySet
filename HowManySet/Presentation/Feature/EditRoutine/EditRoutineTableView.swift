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

    /// RxDataSources를 위한 DataSource 타입 별칭
    typealias DataSource = RxTableViewSectionedReloadDataSource<EditRoutineSection>

    /// 외부에서 바인딩 가능하도록 노출된 RxDataSource
    var rxDataSource: DataSource?

    // MARK: - Initializer
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        bind()
        delegate = self
        backgroundColor = .background
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Binding
    /// RxDataSource 바인딩 설정 및 셀 구성 정의
    func bind() {
        rxDataSource = DataSource(configureCell: { (dataSource, tableView, indexPath, item) in

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
            cell.moreButtonTapped
                .subscribe(with: self) { owner, _ in
                    owner.cellMoreButtonTapped.accept(indexPath)
                }.disposed(by: cell.disposeBag)
                
            cell.configure(model: item)
            return cell
        })
        
        cellMoreButtonTapped
            .subscribe{ indexPath in
                print(indexPath)
            }.disposed(by: disposeBag)
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
