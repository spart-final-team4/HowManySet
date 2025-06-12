import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

final class RoutineListViewController: UIViewController, View {
    var disposeBag = DisposeBag()

    let routineListView = RoutineListView()
    private weak var coordinator: RoutineListCoordinatorProtocol?

    init(reactor: RoutineListViewReactor, coordinator: RoutineListCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = routineListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setRegisters()

        reactor?.action.onNext(.viewDidLoad)
    }

    // MARK: - Bind
    func bind(reactor: RoutineListViewReactor) {
        // routines -> tableView 바인딩
        reactor.state
            .map(\.routines)
            .bind(to: routineListView.publicRoutineTableView.rx.items(
                cellIdentifier: RoutineCell.identifier,
                cellType: RoutineCell.self
            )) { _, routine, cell in
                cell.configure(with: routine)
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
}

// MARK: - Calendar buttons addTarget
extension RoutineListViewController: UITableViewDelegate {
    /// TableView Cell의 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIScreen.main.bounds.height * 0.13
    }
}
