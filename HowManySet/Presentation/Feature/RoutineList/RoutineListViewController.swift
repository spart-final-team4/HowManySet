import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

final class RoutineListViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var caller: ViewCaller
    
    private lazy var routineListView = RoutineListView(frame: .zero, caller: caller)
    
    private weak var coordinator: RoutineListCoordinatorProtocol?

    // RxDataSource 사용을 위한 Model 생성
    typealias RoutineSection = SectionModel<String, WorkoutRoutine>

    // RxDataSource 정의
    let dataSource = RxTableViewSectionedReloadDataSource<RoutineSection>(
        configureCell: { _, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RoutineCell.identifier, for: indexPath) as? RoutineCell else {
                return UITableViewCell()
            }
            cell.configure(with: item)
            return cell
        }
    )

    // MARK: - Init
    init(reactor: RoutineListViewReactor, coordinator: RoutineListCoordinatorProtocol, caller: ViewCaller) {
        self.caller = caller
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.viewWillAppear)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setRegisters()
    }

    // MARK: - Bind
    func bind(reactor: RoutineListViewReactor) {
        // "새 루틴 추가" 버튼이 눌렸을 때 화면이 전환되고 reactor에 바인딩
        routineListView.publicAddNewRoutineButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.routineListView.publicAddNewRoutineButton.animateTap {
                    if owner.presentingViewController != nil {
                        owner.dismiss(animated: true)
                    }
                    owner.coordinator?.presentRoutineNameView()
                }
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { state in
                state.routines.map { SectionModel(model: "", items: [$0]) }  // 루틴마다 하나의 섹션
            }
            .bind(to: routineListView.publicRoutineTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // tableView.delegate 바인딩
        routineListView.publicRoutineTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isLoading in
                if isLoading {
                    LoadingIndicator.showLoadingIndicator()
                } else {
                    LoadingIndicator.hideLoadingIndicator()
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Delegate & Register
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
        /* height를 기본값으로 지정하는 이유
         => 다른 기기에서 셀 내부의 내용이 다 잘림. 어차피 스크롤이 되기 때문에 기본값으로 지정해줘도 괜찮다고 생각함. */
        116
    }

    /// TableView Cell이 선택되었을 때 실행하는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        // 셀 터치 애니메이션
        cell.animateTap { [weak self] in
            guard let self else { return }
            let routine = dataSource.sectionModels[indexPath.section].items[indexPath.row]

            if caller == .fromHome {
                coordinator?.presentEditRoutinView(with: routine)
            } else {
                coordinator?.pushEditRoutineView(with: routine)
            }
        }
    }

    /// trailing -> leading 방향으로 스와이프하는 메서드
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: String(localized: "삭제")) { [weak self] _, _, completion in
            self?.reactor?.action.onNext(.deleteRoutine(indexPath))
            self?.showToast(x: 0, y: 80, message: String(localized: "루틴이 삭제되었어요!"))
            completion(true)
        }

        deleteAction.backgroundColor = .error
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    /// tableView의 섹션 안에 있는 footerView를 설정하는 메서드
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear
        return footer
    }

    /// tableView의 섹션 안에 있는 footerView의 높이를 정하는 메서드
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
}
