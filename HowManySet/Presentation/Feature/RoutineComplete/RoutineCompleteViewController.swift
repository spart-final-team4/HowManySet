//
//  CompleteViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/4/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import ReactorKit

final class RoutineCompleteViewController: UIViewController, View {
    
    // MARK: - Properties
    private weak var coordinator: RoutineCompleteCoordinatorProtocol?
    
    var disposeBag = DisposeBag()
    
    private let exerciseCompletedText = "운동 완료! 수고했어요"
    private let exerciseRecordSavedText = "운동 기록 저장됨"
    private let memoPlaceHolderText = "메모를 입력해 주세요."
    private let confirmText = "확인"
    
    // MARK: - UI Components
    private lazy var topLabelVStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 14
    }
    
    private lazy var exerciseCompletedLabel = UILabel().then {
        $0.text = exerciseCompletedText
        $0.font = .systemFont(ofSize: 24, weight: .medium)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var exerciseInfoLabel = UILabel().then {
        $0.text = "루틴명 | 2025.06.06 운동 기록 저장됨"
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .lightGray
        $0.textAlignment = .center
    }
    
    private lazy var cardContentsContainer = UIView().then {
        $0.backgroundColor = .cardBackground
        $0.layer.cornerRadius = 20
    }
    
    private lazy var progressView = ArchProgressView().then {
        $0.progress = 0.8
        $0.trackColor = .textTertiary
        $0.progressColor = .brand
        $0.lineWidth = 22
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var percentageLabel = UILabel().then {
        $0.text = "80%"
        $0.font = .systemFont(ofSize: 36, weight: .semibold)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var exerciseTimeLabel = UILabel().then {
        $0.text = "40:38"
        $0.font = .systemFont(ofSize: 20, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var exerciseAndSetInfoLabel = UILabel().then {
        $0.text = "5개 운동, 25세트"
        $0.font = .systemFont(ofSize: 20, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var timeIcon = UIImageView().then {
        $0.image = UIImage(systemName: "clock")
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var exerciseIcon = UIImageView().then {
        $0.image = UIImage(systemName: "dumbbell")
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var timeInfoHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .leading
    }
    
    private lazy var exerciseInfoHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .leading
    }
    
    private lazy var routineStatisticsContainer = UIView().then {
        $0.backgroundColor = .tabBarBG
        $0.layer.cornerRadius = 20
    }
    
    private lazy var shareButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .systemGray2
        $0.layer.cornerRadius = 22
    }
    
    private lazy var memoTextView = UITextView().then {
        $0.backgroundColor = .black
        $0.textColor = .placeholderText
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.layer.cornerRadius = 12
        $0.text = memoPlaceHolderText
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    private lazy var confirmButton = UIButton().then {
        $0.setTitle(confirmText, for: .normal)
        $0.setTitleColor(.background, for: .normal)
        $0.backgroundColor = .brand
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.layer.cornerRadius = 12
    }
    
    // MARK: - Initializer
    init(reactor: RoutineCompleteViewReactor, coordinator: RoutineCompleteCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
        
        self.hidesBottomBarWhenPushed = true
        self.navigationItem.hidesBackButton = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self

        setupUI()
    }
}

// MARK: - UI Methods
private extension RoutineCompleteViewController {
    
    func setupUI() {
        view.backgroundColor = .background
        
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        
        view.addSubviews(
            topLabelVStack,
            cardContentsContainer,
            percentageLabel,
            memoTextView,
            confirmButton
        )
        
        topLabelVStack.addArrangedSubviews(exerciseCompletedLabel, exerciseInfoLabel)
        cardContentsContainer.addSubviews(progressView, routineStatisticsContainer, shareButton)
        routineStatisticsContainer.addSubviews(timeInfoHStack, exerciseInfoHStack)
        timeInfoHStack.addArrangedSubviews(timeIcon, exerciseTimeLabel)
        exerciseInfoHStack.addArrangedSubviews(exerciseIcon, exerciseAndSetInfoLabel)
    }
    
    func setConstraints() {
        
        topLabelVStack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        cardContentsContainer.snp.makeConstraints {
            $0.top.equalTo(topLabelVStack.snp.bottom).offset(14)
            $0.height.equalToSuperview().multipliedBy(0.43)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        shareButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(28)
            $0.width.height.equalTo(44)
        }
        
        progressView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(72)
            $0.width.height.equalTo(cardContentsContainer.snp.width).multipliedBy(0.63)
        }
                
        percentageLabel.snp.makeConstraints {
            $0.centerX.equalTo(progressView)
            $0.centerY.equalTo(progressView).offset(-10)
        }
        
        timeInfoHStack.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(24)
        }
        
        exerciseInfoHStack.snp.makeConstraints {
            $0.bottom.leading.equalToSuperview().inset(24)
        }
        
        routineStatisticsContainer.snp.makeConstraints {
            $0.height.equalTo(cardContentsContainer.snp.height).multipliedBy(0.31)
            $0.horizontalEdges.equalTo(cardContentsContainer).inset(28)
            $0.bottom.equalTo(cardContentsContainer.snp.bottom).inset(28)
        }
        
        timeIcon.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        exerciseIcon.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        memoTextView.snp.makeConstraints {
            $0.top.equalTo(cardContentsContainer.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(cardContentsContainer.snp.height).multipliedBy(0.39)
        }
        
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }
}

// MARK: - UITextViewDelegate
extension RoutineCompleteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == memoPlaceHolderText {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = memoPlaceHolderText
            textView.textColor = .placeholderText
        }
    }
}

// MARK: - Reactor Binding
extension RoutineCompleteViewController {
 
    func bind(reactor: RoutineCompleteViewReactor) {
        
    }
}
