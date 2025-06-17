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

final class RoutineCompleteViewController: UIViewController {
    
    // MARK: - Properties
    private weak var coordinator: RoutineCompleteCoordinatorProtocol?
    
    // UI에 보여질 운동 통계 요약 데이터
    var workoutSummary: WorkoutSummary?
    
    var disposeBag = DisposeBag()
    
    private let exerciseCompletedText = "운동 완료! 수고했어요"
    private let exerciseRecordSavedText = "운동 기록 저장됨"
    private let memoPlaceHolderText = "메모를 입력해 주세요."
    private let confirmText = "확인"
    
    // MARK: - UI Components
    private lazy var mainContentsContainer = UIView()
    
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
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .lightGray
        $0.textAlignment = .center
    }
    
    private lazy var cardContentsContainer = UIView().then {
        $0.backgroundColor = .cardBackground
        $0.layer.cornerRadius = 20
    }
    
    private lazy var progressView = ArchProgressView().then {
        $0.progress = 0
        $0.trackColor = .textTertiary
        $0.progressColor = .brand
        $0.lineWidth = 22
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var percentageLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 36, weight: .semibold)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var exerciseTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var exerciseAndSetInfoLabel = UILabel().then {
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
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.layer.cornerRadius = 12
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
    init(coordinator: RoutineCompleteCoordinatorProtocol, workoutSummary: WorkoutSummary) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
        self.workoutSummary = workoutSummary
        
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
        bindUIEvents()
        
        if let workoutSummary {
            print("configure 호출")
            print("🎬 [WorkoutSummary]: \(workoutSummary)")
            configure(with: workoutSummary)
        }
    }
}

// MARK: - UI Methods
private extension RoutineCompleteViewController {
    
    func setupUI() {
        view.backgroundColor = .background
        
        setViewHiearchy()
        setConstraints()
        configureKeyboardNotifications()
    }
    
    func setViewHiearchy() {
        
        view.addSubview(mainContentsContainer)
        
        mainContentsContainer.addSubviews(
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
        
        mainContentsContainer.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.verticalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        topLabelVStack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview()
        }
        
        cardContentsContainer.snp.makeConstraints {
            $0.top.equalTo(topLabelVStack.snp.bottom).offset(14)
            $0.height.equalTo(view).multipliedBy(0.43)
            $0.horizontalEdges.equalToSuperview()
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
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(cardContentsContainer.snp.height).multipliedBy(0.39)
        }
        
        confirmButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview()
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

// MARK: - Private Methods
private extension RoutineCompleteViewController {
 
    func configure(with workoutSummary: WorkoutSummary) {
        let routineName = workoutSummary.routineName
        let todayDate = workoutSummary.date.toDateLabelWithYear()
        let totalTime = workoutSummary.totalTime.toWorkOutTimeLabel()
        let routineDidProgress = workoutSummary.routineDidProgress
        let exerciseDidCount = workoutSummary.exerciseDidCount
        let setDidCount = workoutSummary.setDidCount
        let routineMemo = workoutSummary.routineMemo
        
        exerciseInfoLabel.text = "\(routineName) | \(todayDate) \(exerciseRecordSavedText)"
        progressView.setProgress(CGFloat(routineDidProgress))
        percentageLabel.text = "\(Int(routineDidProgress * 100))%"
        exerciseTimeLabel.text = totalTime
        exerciseAndSetInfoLabel.text = "\(exerciseDidCount)개 운동, \(setDidCount)세트"
        memoTextView.text = routineMemo
    }
}

// MARK: - Rx Binding
private extension RoutineCompleteViewController {
    
    func bindUIEvents() {
        
        confirmButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                
                self.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.presentShareActivity()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Keyboard
private extension RoutineCompleteViewController {
    
    private func configureKeyboardNotifications() {
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .bind(onNext: { [weak self] keyboardHeight in
                guard let self else { return }
                print("키보드 나타남")
        
                UIView.animate(withDuration: 0.3) {
                    self.mainContentsContainer.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight/2)
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .bind(onNext: { [weak self] _ in
                guard let self else { return }
                print("키보드 사라짐")

                UIView.animate(withDuration: 0.3) {
                    self.mainContentsContainer.transform = .identity
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Share Methods
private extension RoutineCompleteViewController {
    
    func presentShareActivity() {
        
        guard let workoutSummary else { return }
        
        // 공유할 텍스트 생성
        let shareText = createShareText(from: workoutSummary)
        // 공유할 아이템들
        var activityItems: [Any] = [shareText]
        
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // 공유 버튼 누를 시 자동으로 운동 카드 부분 캡쳐
        // 실기기 테스트 필요
        if let screenshot = captureWorkoutSummaryScreenshot() {
            activityItems.append(screenshot)
        }
        
        // 제외할 정보들
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact
        ]
        
        present(activityViewController, animated: true)
    }
    
    
    func createShareText(from summary: WorkoutSummary) -> String {
        
        let routineName = summary.routineName
        let date = summary.date.toDateLabelWithYear()
        let totalTime = summary.totalTime.toWorkOutTimeLabel()
        let progress = Int(summary.routineDidProgress * 100)
        let exerciseCount = summary.exerciseDidCount
        let setCount = summary.setDidCount
        
        let shareText = """
        운동 완료!
        
        📋 루틴: \(routineName)
        📅 날짜: \(date)
        ⏱️ 운동시간: \(totalTime)
        📊 진행률: \(progress)%
        💪 \(exerciseCount)개 운동, \(setCount)세트
        
        #운동 #헬스 #HowManySet
        """
        
        return shareText
    }
    
    func captureWorkoutSummaryScreenshot() -> UIImage? {
        // 운동 요약 카드 부분만 캡처
        return cardContentsContainer.asImage()
    }
}
