import UIKit
import ReactorKit
import RxSwift
import SnapKit

final class NicknameInputViewController: UIViewController, View {

    var disposeBag = DisposeBag()
    var reactor: NicknameInputViewReactor!

    private let nicknameInputView = NicknameInputView()
    private weak var coordinator: NicknameInputCoordinatorProtocol?

    init(reactor: NicknameInputViewReactor, coordinator: NicknameInputCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(reactor: reactor)
    }

    private func setupUI() {
        view.backgroundColor = .background
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(nicknameInputView)
        nicknameInputView.snp.makeConstraints { $0.edges.equalToSuperview() }
        setupKeyboardObserver()
        bindUIEvents()
    }

    func bind(reactor: NicknameInputViewReactor) {
        nicknameInputView.nicknameTextField.rx.text.orEmpty
            .map(NicknameInputViewReactor.Action.inputNickname)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        nicknameInputView.nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.nicknameInputView.nextButton.animateTap {
                    self?.reactor.action.onNext(.completeNicknameSetting)
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isNicknameValid }
            .distinctUntilChanged()
            .bind(to: nicknameInputView.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isNicknameValid }
            .distinctUntilChanged()
            .bind { [weak self] isValid in
                self?.nicknameInputView.nextButton.backgroundColor = isValid ? .brand : .darkGray
                self?.nicknameInputView.nextButton.setTitleColor(isValid ? .black : .lightGray, for: .normal)
            }
            .disposed(by: disposeBag)

        reactor.state.filter { $0.isNicknameComplete }
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.coordinator?.completeNicknameInput()
            }
            .disposed(by: disposeBag)
    }

    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let height = keyboardFrame.cgRectValue.height
        let safeBottom = view.safeAreaInsets.bottom
        let adjustHeight = height - safeBottom
        nicknameInputView.adjustButtonForKeyboard(keyboardHeight: adjustHeight)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        nicknameInputView.adjustButtonForKeyboard(keyboardHeight: 0)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    private func bindUIEvents() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
