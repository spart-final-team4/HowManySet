import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

final class RecordDetailViewController: UIViewController, View {

    // MARK: - Properties
    let recordDetailView = RecordDetailView()
    var disposeBag = DisposeBag()

    // MARK: - DataSource
    private let dataSource = RxCollectionViewSectionedReloadDataSource<RecordDetailSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
        switch item {
        case let .summary(record):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SummaryInfoCell.identifier,
                for: indexPath
            ) as? SummaryInfoCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: record)
            return cell

        case let .set(index, set):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WorkoutDetailInfoCell.identifier,
                for: indexPath
            ) as? WorkoutDetailInfoCell else {
                return UICollectionViewCell()
            }
            cell.configure(index: index, set: set)
            return cell

        case let .memo(comment):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemoInfoCell.identifier,
                for: indexPath
            ) as? MemoInfoCell else {
                return UICollectionViewCell()
            }
            cell.configure(comment: comment)
            return cell
        }
    },
    configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
        switch dataSource.sectionModels[indexPath.section].model {
        case let .workoutDetail(workout) where kind == UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: WorkoutDetailHeaderView.identifier,
                for: indexPath
            ) as? WorkoutDetailHeaderView else {
                return UICollectionReusableView()
            }
            header.configure(title: workout.name)
            return header
        default:
            return UICollectionReusableView()
        }
    }
    )

    // MARK: - Initializer
    init(reactor: RecordDetailViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func loadView() {
        view = recordDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
}

// MARK: - UI Methods
extension RecordDetailViewController {
    /// 리액터 Binding
    func bind(reactor: RecordDetailViewReactor) {
        let record = reactor.currentState.record

        // 요약뷰 구성
        let summarySection = RecordDetailSectionModel(
            model: .summary,
            items: [.summary(record: record)]
        )

        // 운동 세부 정보 섹션
        let workoutSections = record.workoutRoutine.workouts.enumerated().map { (_, workout) in
            let items = workout.sets.enumerated().map { (index, set) in
                RecordDetailSectionItem.set(index: index, set: set)
            }
            return RecordDetailSectionModel(
                model: .workoutDetail(workout: workout),
                items: items
            )
        }

        // 메모 섹션
        let memoSection = RecordDetailSectionModel(
            model: .memo(comment: record.comment),
            items: [.memo(comment: record.comment)]
        )

        // 전체 섹션
        let allSections = [summarySection] + workoutSections + [memoSection]

        // 레이아웃 업데이트
        recordDetailView.updateLayout(with: allSections)

        // 이후에 collecitonView에 데이터 바인딩
        Observable.just(allSections)
            .bind(to: recordDetailView.publicCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    /// 컬랙션 뷰 Setup (셀 register)
    private func setupCollectionView() {
        let collectionView = recordDetailView.publicCollectionView

        // 첫번째 section cell
        collectionView.register(
            SummaryInfoCell.self,
            forCellWithReuseIdentifier: SummaryInfoCell.identifier
        )

        // 두번째 section cell
        collectionView.register(
            WorkoutDetailInfoCell.self,
            forCellWithReuseIdentifier: WorkoutDetailInfoCell.identifier
        )

        // 두번째 section 헤더 뷰
        collectionView.register(
            WorkoutDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: WorkoutDetailHeaderView.identifier
        )

        // 세번째 section cell
        collectionView.register(
            MemoInfoCell.self,
            forCellWithReuseIdentifier: MemoInfoCell.identifier
        )
    }
}

