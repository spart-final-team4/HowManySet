//
//  WorkoutOptionViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/5/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import ReactorKit

final class WorkoutOptionViewController: UIViewController {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private let editText = "편집"
    private let editRoutineButtonText = "운동 목록 변경"
    private let memoText = "메모"
    private let memoPlaceHolderText = "메모를 입력해주세요."
    
    // MARK: - UI Components
    private lazy var containerView = UIView()
    
    private lazy var editLabel = UILabel().then {
        $0.text = editText
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    private lazy var editRoutineButton = UIButton().then {
        $0.backgroundColor = .disabledButton
        $0.layer.cornerRadius = 12
        $0.setTitle(editRoutineButtonText, for: .normal)
    }
    
    private lazy var memoLabel = UILabel().then {
        $0.text = memoText
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    private lazy var memoTextView = UITextView().then {
        $0.backgroundColor = .bsInputFieldBG
        $0.text = memoPlaceHolderText
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 16)
        $0.layer.cornerRadius = 12
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    
    // MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        memoTextView.delegate = self
    }
    
}

// MARK: - UI Methods
private extension WorkoutOptionViewController {
    
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        view.backgroundColor = .systemBackground
    }
    
    func setViewHierarchy() {
        view.addSubview(containerView)
        [editLabel, editRoutineButton, memoLabel, memoTextView].forEach {
            containerView.addSubview($0)
        }
    }
    
    func setConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        editLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        editRoutineButton.snp.makeConstraints {
            $0.top.equalTo(editLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }

        memoLabel.snp.makeConstraints {
            $0.top.equalTo(editRoutineButton.snp.bottom).offset(24)
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
extension WorkoutOptionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == memoPlaceHolderText {
            textView.text = ""
            textView.textColor = .white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = memoPlaceHolderText
            textView.textColor = .lightGray
        }
    }
}
