import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

final class RoutineListViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag = DisposeBag()

    let routineListView = RoutineListView()
    private var coordinator: RoutineListCoordinatorProtocol?

    // DiffableDataSource 정의
    private var dataSource: UITableViewDiffableDataSource<Section, WorkoutRoutine>!

    // Section 정의
    enum Section {
        case main
    }

    // MARK: - Init
    init(reactor: RoutineListViewReactor, coordinator: RoutineListCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func loadView() {
        view = routineListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setRegisters()
        configureDataSource()
        // MockData 표시
        applySnapshot(with: WorkoutRoutine.mockData)
    }

    // MARK: - Bind
    func bind(reactor: RoutineListViewReactor) {
        // "새 루틴 추가" 버튼이 눌렸을 때 화면이 전환되고 reactor에 바인딩
        routineListView.publicAddNewRoutineButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.coordinator?.presentRoutineNameView()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Delegate & DataSource & Register
private extension RoutineListViewController {
    func setDelegates() {
        routineListView.publicRoutineTableView.delegate = self
    }

    func setRegisters() {
        routineListView.publicRoutineTableView.register(RoutineCell.self, forCellReuseIdentifier: RoutineCell.identifier)
    }

    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, WorkoutRoutine>(
            tableView: routineListView.publicRoutineTableView
        ) { tableView, indexPath, routine in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: RoutineCell.identifier,
                for: indexPath
            ) as? RoutineCell else {
                return UITableViewCell()
            }

            // 데이터를 cell에 주입
            cell.configure(with: routine)
            return cell
        }
    }
}

// MARK: - Snapshot
extension RoutineListViewController {
    /// 현재 보여줄 데이터 전체 상태를 전달하는 메서드
    func applySnapshot(with routines: [WorkoutRoutine], animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, WorkoutRoutine>()
        // Section 추가
        snapshot.appendSections([.main])
        // Item 추가
        snapshot.appendItems(routines, toSection: .main)
        // 실제 적용
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - Calendar buttons addTarget
extension RoutineListViewController: UITableViewDelegate {
    /// TableView Cell의 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /* height를 기본값으로 지정하는 이유
         => 다른 기기에서 셀 내부의 내용이 다 잘림. 어차피 스크롤이 되기 때문에 기본값으로 지정해줘도 괜찮다고 생각함. */
        132
    }
}
