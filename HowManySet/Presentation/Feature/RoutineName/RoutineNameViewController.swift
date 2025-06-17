import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class RoutineNameViewController: UIViewController, View {
    // MARK: - Properties
    let routineNameView = RoutineNameView()
    private weak var coordinator: RoutineListCoordinatorProtocol?
    var disposeBag = DisposeBag()

    // MARK: - Init
    init(reactor: RoutineNameReactor, coordinator: RoutineListCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 커서 자동 위치
        routineNameView.publicRoutineNameTF.becomeFirstResponder()
    }
}

// MARK: - extension
extension RoutineNameViewController {
    func bind(reactor: RoutineNameReactor) {
        // 텍스트 필드 입력에 따른 버튼 활성화
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

        // 버튼 탭 이벤트
        routineNameView.publicNextButton.rx.tap
            .withLatestFrom(routineNameView.publicRoutineNameTF.rx.text.orEmpty)
            .bind(with: self) { owner, text in
                reactor.action.onNext(.setRoutineName(text))
                owner.dismiss(animated: true) {
                    owner.coordinator?.pushEditExcerciseView(routineName: text)
                }
            }
            .disposed(by: disposeBag)
        
        // 화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .bind { [weak self] _ in
                guard let self else { return }
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
}
