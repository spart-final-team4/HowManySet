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
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .distinctUntilChanged()
            .bind(with: self) { owner, isEnabled in
                let button = owner.routineNameView.publicNextButton
                button.isEnabled = isEnabled
                button.backgroundColor = isEnabled ? .green6 : .disabledButton
                button.setTitleColor(isEnabled ? .background : .dbTypo, for: .normal)
            }
            .disposed(by: disposeBag)

        // 버튼 탭 이벤트
        routineNameView.publicNextButton.rx.tap
            .withLatestFrom(routineNameView.publicRoutineNameTF.rx.text.orEmpty)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // 혹시나 만약을 대비하여 여기도 추가
            .bind(with: self) { owner, text in
                reactor.action.onNext(.setRoutineName(text))
                owner.dismiss(animated: true) {
                    owner.coordinator?.pushEditExcerciseView(routineName: text)
                }
            }
            .disposed(by: disposeBag)
        
//        // 화면 탭하면 키보드 내리기
//        let tapGesture = UITapGestureRecognizer()
//        tapGesture.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapGesture)
//
//        tapGesture.rx.event
//            .bind { [weak self] _ in
//                guard let self else { return }
//                self.view.endEditing(true)
//            }
//            .disposed(by: disposeBag)
/*
 다음 버튼을 누를 때 두번 탭해야하는 불편함이 생김
 => 주석처리를 하게 되면 버튼을 누를때 한번만 눌러도 다음 화면으로 넘어감
 => 어차피 전체 화면을 덮는 모달이 아니기 때문에 키보드를 취소하고 싶다면 모달 뒤를 탭하면 된다고 생각함
*/
    }
}
