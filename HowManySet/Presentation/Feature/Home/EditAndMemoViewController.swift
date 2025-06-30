//
//  EditAndMemoViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/5/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class EditAndMemoViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private let editText = "편집"
    private let editRoutineButtonText = "운동 목록 변경"
    private let memoText = "메모"
    private let memoPlaceHolderText = "메모를 입력해주세요."
    
    private weak var coordinator: HomeCoordinatorProtocol?
    
    // MARK: - UI Components
    private lazy var containerView = UIView()
    
    // TODO: 추후에 배포 후 추가 예정
//    private lazy var editLabel = UILabel().then {
//        $0.text = editText
//        $0.font = .pretendard(size: 20, weight: .semibold)
//    }
//
//    private lazy var editRoutineButton = UIButton().then {
//        $0.backgroundColor = .disabledButton
//        $0.layer.cornerRadius = 12
//        $0.setTitle(editRoutineButtonText, for: .normal)
//        // 버튼 타이틀 정렬
//        $0.contentHorizontalAlignment = .leading
//        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
//    }
    
    private lazy var memoLabel = UILabel().then {
        $0.text = memoText
        $0.font = .pretendard(size: 20, weight: .semibold)
    }
    
    lazy var memoTextView = UITextView().then {
        $0.backgroundColor = .bsInputFieldBG
        $0.text = memoPlaceHolderText
        $0.textColor = .grey3
        $0.font = .pretendard(size: 16)
        $0.layer.cornerRadius = 12
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        // 키보드 관련
        $0.autocorrectionType = .no // 자동 수정 끔
        $0.spellCheckingType = .no // 맞춤법 검사 끔
        $0.smartInsertDeleteType = .no // 스마트 삽입/삭제 끔
        $0.autocapitalizationType = .none // 영문으로 시작할 때 자동 대문자 끔
    }
    
    
    // MARK: - Initializer
    init(reactor: HomeViewReactor, coordinator: HomeCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUIEvents()
        
        memoTextView.delegate = self
        applyInitialMemoPlaceholderIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let newMemo = self.memoTextView.text
        reactor?.action.onNext(.updateCurrentExerciseMemoWhenDismissed(with: newMemo ?? ""))
    }
    
}

// MARK: - UI Methods
private extension EditAndMemoViewController {
    
    func setupUI() {
        view.backgroundColor = .bottomSheetBG
        
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        view.addSubview(containerView)
        [/*editLabel, editRoutineButton,*/ memoLabel, memoTextView].forEach {
            containerView.addSubview($0)
        }
    }
    
    func setConstraints() {
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(68)
        }
        
//        editLabel.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.leading.equalToSuperview()
//        }
//
//        editRoutineButton.snp.makeConstraints {
//            $0.top.equalTo(editLabel.snp.bottom).offset(12)
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(48)
//        }
        
        memoLabel.snp.makeConstraints {
//            $0.top.equalTo(editRoutineButton.snp.bottom).offset(24)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        memoTextView.snp.makeConstraints {
            $0.top.equalTo(memoLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
}

// MARK: - UITextViewDelegate
extension EditAndMemoViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == memoPlaceHolderText {
            textView.text = nil
            textView.textColor = .white
        }
        textView.layer.borderColor = UIColor.grey4.cgColor
        textView.layer.borderWidth = 1
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = memoPlaceHolderText
            textView.textColor = .grey3
        } else {
            let text = textView.text
            textView.textColor = .white
            print("📋 입력된 메모: \(String(describing: text))")
        }
        textView.layer.borderWidth = 0
    }
}

extension EditAndMemoViewController {
    /// placeholder 상태 강제 적용 메서드
    private func applyInitialMemoPlaceholderIfNeeded() {
        let text = memoTextView.text ?? ""
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text == memoPlaceHolderText {
            memoTextView.text = memoPlaceHolderText
            memoTextView.textColor = .grey3
        }
    }

    func bind(reactor: HomeViewReactor) {
        
        reactor.state.map { $0.currentExerciseIndex }
            .distinctUntilChanged()
            .bind { [weak self] index in
                guard let self else { return }
                let memoText = reactor.currentState.workoutCardStates[index].memoInExercise

                if memoText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                    self.memoTextView.text = self.memoPlaceHolderText
                    self.memoTextView.textColor = .grey3
                } else {
                    self.memoTextView.text = memoText
                    self.memoTextView.textColor = .white
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Rx Methods
private extension EditAndMemoViewController {
    
    func bindUIEvents() {
        
//        editRoutineButton.rx.tap
//            .bind(onNext: { [weak self] _ in
//                guard let self else { return }
//                print("루틴 수정 버튼 클릭")
//                self.dismiss(animated: true) {
//                    // TODO: 검토 및 테스트 필요
//                    guard let routine = self.reactor?.currentState.workoutRoutine else { return }
//                    self.coordinator?.presentEditRoutineView(with: routine)
//                }
//            }).disposed(by: disposeBag)
        
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
