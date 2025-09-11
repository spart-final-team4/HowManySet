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
import RxCocoa
import ReactorKit
import GoogleMobileAds

final class RoutineCompleteViewController: UIViewController, View {
    
    // MARK: - Properties
    private weak var coordinator: RoutineCompleteCoordinatorProtocol?
    
    /// UI에 보여질 운동 통계 요약 데이터
    var workoutSummary: WorkoutSummary?
    
    var disposeBag = DisposeBag()
    
    /// 전면광고
    var interstitial: InterstitialAd?
    /// AdMob 테스트용 ID
    private let testAdId = "ca-app-pub-3940256099942544/4411468910"
    /// Google Mobile Ads SDK 시작 여부
    private var isMobileAdsStartCalled = false
    
    var timer: Timer?
    var timePassed = 0.0
    
    private let exerciseCompletedText = String(localized: "운동 완료! 수고했어요")
    private let exerciseRecordSavedText = String(localized: "운동 기록 저장됨")
    private let memoPlaceHolderText = String(localized: "메모를 입력해주세요.")
    private let confirmText = String(localized: "확인")
        
    private let cardInset: CGFloat = UIScreen.main.bounds.width <= 375 ? 24 : 28
    private let statInset: CGFloat = UIScreen.main.bounds.width <= 375 ? 20 : 24
    private let fontSize: CGFloat = UIScreen.main.bounds.width <= 375 ? 18 : 20
    private let iconSize: CGFloat = UIScreen.main.bounds.width <= 375 ? 22 : 24

    // MARK: - UI Components
    private lazy var mainContentsContainer = UIView()
    
    private lazy var topLabelVStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 14
    }
    
    private lazy var exerciseCompletedLabel = UILabel().then {
        $0.text = exerciseCompletedText
        $0.font = .pretendard(size: 24, weight: .medium)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var exerciseInfoLabel = UILabel().then {
        $0.font = .pretendard(size: 12, weight: .regular)
        $0.textColor = .lightGray
        $0.textAlignment = .center
        $0.numberOfLines = 1
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
    
    private lazy var routineStatisticsVStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
    }
    
    private lazy var percentageLabel = UILabel().then {
        $0.font = .pretendard(size: 36, weight: .semibold)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var exerciseTimeLabel = UILabel().then {
        $0.font = .pretendard(size: fontSize, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
        $0.numberOfLines = 1
    }
    
    private lazy var exerciseAndSetInfoLabel = UILabel().then {
        $0.font = .pretendard(size: fontSize, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
        $0.numberOfLines = 1
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
        $0.setImage(UIImage(named: "share"), for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
        $0.backgroundColor = .systemGray2
        $0.layer.cornerRadius = 22
    }
    
    private lazy var memoTextView = UITextView().then {
        $0.backgroundColor = .grey8
        $0.text = memoPlaceHolderText
        $0.textColor = .grey3
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.layer.cornerRadius = 12
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        // 키보드 관련
        $0.autocorrectionType = .no // 자동 수정 끔
        $0.spellCheckingType = .no // 맞춤법 검사 끔
        $0.smartInsertDeleteType = .no // 스마트 삽입/삭제 끔
        $0.autocapitalizationType = .none // 영문으로 시작할 때 자동 대문자 끔
    }
    
    private lazy var confirmButton = UIButton().then {
        $0.setTitle(confirmText, for: .normal)
        $0.setTitleColor(.background, for: .normal)
        $0.backgroundColor = .brand
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.layer.cornerRadius = 12
    }
    
    // MARK: - Initializer
    init(coordinator: RoutineCompleteCoordinatorProtocol,
         workoutSummary: WorkoutSummary,
         homeViewReactor: HomeViewReactor
    ) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
        self.workoutSummary = workoutSummary
        self.reactor = homeViewReactor
        
        self.hidesBottomBarWhenPushed = true
        self.navigationItem.hidesBackButton = true
        
        startGoogleMobileAdsSDK()
        
        // AdMob 딜레이 테스트용 타이머
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { Timer in
            self.timePassed += Timer.timeInterval
            print(self.timePassed)
        })

//        self.transitioningDelegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadingIndicator.showLoadingIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            LoadingIndicator.hideLoadingIndicator()
        }
        
        memoTextView.delegate = self
        
        setupUI()
        bindUIEvents()
        
        if let workoutSummary {
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
        topLabelVStack.addArrangedSubviews(
            exerciseCompletedLabel,
            exerciseInfoLabel
        )
        cardContentsContainer.addSubviews(
            progressView,
            routineStatisticsContainer,
            shareButton
        )
        routineStatisticsContainer.addSubview(routineStatisticsVStack)
        routineStatisticsVStack.addArrangedSubviews(
            timeInfoHStack,
            exerciseInfoHStack
        )
        timeInfoHStack.addArrangedSubviews(
            timeIcon,
            exerciseTimeLabel
        )
        exerciseInfoHStack.addArrangedSubviews(
            exerciseIcon,
            exerciseAndSetInfoLabel
        )
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

        progressView.snp.makeConstraints {
            $0.top.equalTo(shareButton.snp.bottom).offset(-20)
            $0.width.height.equalTo(cardContentsContainer.snp.height).multipliedBy(0.63)
            $0.centerX.equalToSuperview()
        }
                
        percentageLabel.snp.makeConstraints {
            $0.centerX.equalTo(progressView)
            $0.centerY.equalTo(progressView).offset(-10)
        }
        
        shareButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(cardInset)
            $0.width.height.equalTo(44)
        }
        
        routineStatisticsContainer.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.31)
            $0.horizontalEdges.equalToSuperview().inset(cardInset)
            $0.bottom.equalToSuperview().inset(cardInset)
        }
        
        routineStatisticsVStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(statInset)
        }
        
        timeIcon.snp.makeConstraints {
            $0.width.height.equalTo(iconSize)
        }
        
        exerciseIcon.snp.makeConstraints {
            $0.width.height.equalTo(iconSize)
        }
        
        memoTextView.snp.makeConstraints {
            $0.top.equalTo(cardContentsContainer.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(cardContentsContainer.snp.height).multipliedBy(0.39)
        }
        
        confirmButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(56)
        }
    }
}

// MARK: - UITextViewDelegate
extension RoutineCompleteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == memoPlaceHolderText {
            textView.text = nil
            textView.textColor = .white
        }
        textView.layer.borderColor = UIColor.grey3.cgColor
        textView.layer.borderWidth = 1
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = memoPlaceHolderText
            textView.textColor = .grey3
        }
        textView.layer.borderWidth = 0
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
        percentageLabel.text = "\(min(100, Int(routineDidProgress * 100)))%"
        exerciseTimeLabel.text = totalTime
        exerciseAndSetInfoLabel.text = String(format: String(localized: "%d개 운동, %d세트"), exerciseDidCount, setDidCount)
        memoTextView.text = routineMemo

        // placeholder 적용 조건 판단
        if memoTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            memoTextView.text = memoPlaceHolderText
            memoTextView.textColor = .grey3
        } else {
            memoTextView.textColor = .white
        }
    }
}

// MARK: - Rx Binding
private extension RoutineCompleteViewController {
    
    func bindUIEvents() {
        
        shareButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.presentShareActivity()
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

// MARK: - Reactor Binding
extension RoutineCompleteViewController {
    
    func bind(reactor: HomeViewReactor) {
        
        confirmButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return Observable<Void>.create { observer in
                    // 클릭 애니메이션
                    self.confirmButton.animateTap {
                        observer.onNext(())
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .bind { [weak self] action in
                guard let self else { return }
                
                self.presentInterstitial()
                
                let updatedMemo = self.memoTextView.text

                reactor.action.onNext(.confirmButtonClickedForSavingMemo(newMemo: updatedMemo))
                self.navigationController?.popToRootViewController(animated: true)
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
        
                UIView.animate(withDuration: 0.1, animations: {
                    self.mainContentsContainer.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight/2)
                })
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .bind(onNext: { [weak self] _ in
                guard let self else { return }
                print("키보드 사라짐")

                UIView.animate(withDuration: 0.1, animations: {
                    self.mainContentsContainer.transform = .identity
                })
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
        var activityItems: [Any]
        
        // 공유 버튼 누를 시 자동으로 운동 카드 부분 캡쳐
        if let screenshot = captureWorkoutSummaryScreenshot() {
            activityItems = [shareText, screenshot]
        } else {
            activityItems = [shareText]
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // 제외할 정보들
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .print,
            .markupAsPDF,
            .mail,
            .openInIBooks,
            .sharePlay,
            .collaborationInviteWithLink,
            .collaborationCopyLink
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
        // 뷰 전체 캡쳐
        return view.asImage()
    }
}

// MARK: - AdMob: Interstitial
extension RoutineCompleteViewController: FullScreenContentDelegate {
    
    private func startGoogleMobileAdsSDK() {
      DispatchQueue.main.async {
        guard !self.isMobileAdsStartCalled else { return }

        self.isMobileAdsStartCalled = true

        // Initialize the Google Mobile Ads SDK.
        MobileAds.shared.start()
        // Request an ad.
        Task {
          await self.loadInterstitial()
        }
      }
    }

    private func loadInterstitial() async {
        do {
            interstitial = try await InterstitialAd.load(
                with: testAdId, request: Request())
            interstitial?.fullScreenContentDelegate = self
            print("Interstitial ad loaded!")
            timer?.invalidate()
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    private func presentInterstitial() {
        if let ad = self.interstitial {
            ad.present(from: self)
        } else {
            print("Ad wasn't ready")
        }
    }
}


//extension RoutineCompleteViewController: UIViewControllerTransitioningDelegate {
//    
//    func animationController(
//        forPresented presented: UIViewController,
//        presenting: UIViewController,
//        source: UIViewController
//    ) -> UIViewControllerAnimatedTransitioning? {
//        return SlideUpAnimator()
//    }
//}
