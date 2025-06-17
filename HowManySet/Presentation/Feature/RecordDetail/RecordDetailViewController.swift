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
    private let dataSource = RxCollectionViewSectionedReloadDataSource<RecordDetailSectionModel> { dataSource, collectionView, indexPath, item in
        switch dataSource.sectionModels[indexPath.section].model {
        case .summary:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SummaryInfoCell.identifier,
                for: indexPath
            ) as? SummaryInfoCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
        }
    }
    
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
        let sections: [RecordDetailSectionModel] = [
            .init(model: .summary, items: [reactor.currentState.record])
        ]

        Observable.just(sections)
            .bind(to: recordDetailView.publicCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    /// 컬랙션 뷰 Setup (셀 register)
    private func setupCollectionView() {
        recordDetailView.publicCollectionView.register(
            SummaryInfoCell.self,
            forCellWithReuseIdentifier: SummaryInfoCell.identifier
        )
    }
}

