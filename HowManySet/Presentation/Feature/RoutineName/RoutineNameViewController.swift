import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class RoutineNameViewController: UIViewController {

    let routineNameView = RoutineNameView()
    private let reactor: RoutineNameReactor
    private weak var coordinator: RoutineListCoordinatorProtocol?
    private let disposeBag = DisposeBag()

    init(reactor: RoutineNameReactor, coordinator: RoutineListCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func loadView() {
        view = routineNameView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindTextField()
        bindButtonTapped()
    }
}

// MARK: - extension
private extension RoutineNameViewController {
    func bindTextField() {
        routineNameView.publicRoutineNameTF.rx.text.orEmpty
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(with: self) { owner, isEnabled in
                let button = owner.routineNameView.publicNextButton
                button.isEnabled = isEnabled
                button.backgroundColor = isEnabled ? .brand : .disabledButton
                button.setTitleColor(isEnabled ? .black : .dbTypo, for: .normal)
            }
            .disposed(by: disposeBag)
    }

    func bindButtonTapped() {
        routineNameView.publicNextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true) {
                    owner.coordinator?.pushEditExcerciseView()
                }
            }
            .disposed(by: disposeBag)
    }
}
