//
//  MainViewController.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit
import ActivityKit

final class HomeViewController: UIViewController, View {
    
    // MARK: - Properties
    private weak var coordinator: HomeCoordinatorProtocol?
    
    private let homeText = "홈"
    
    var disposeBag = DisposeBag()
    
    /// HomePagingCardView들을 저장하는 List
    private var pagingCardViewContainer = [HomePagingCardView]()
    
    private var currentPage = 0
    private var previousPage = 0
    
    private let screenWidth = UIScreen.main.bounds.width
    private let cardInset: CGFloat = 20
    private let cardWidth = UIScreen.main.bounds.width - 40
    
    // MARK: - UI Components
    private lazy var titleLabel = UILabel().then {
        $0.text = homeText
        $0.font = .systemFont(ofSize: 36, weight: .bold)
    }
    
    private lazy var topTimerHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.isHidden = true
    }
    
    private lazy var workoutTimeLabel = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 36, weight: .bold)
    }
    
    private lazy var pauseButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    private lazy var buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .trailing
        $0.isHidden = true
    }
    
    private lazy var stopButton = UIButton().then {
        $0.layer.cornerRadius = 22
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 16), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        $0.tintColor = .pauseButton
    }
    
    private lazy var forwardButton = UIButton().then {
        $0.layer.cornerRadius = 22
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 16), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    private lazy var routineStartCardView = HomeRoutineStartCardView().then {
        $0.layer.cornerRadius = 20
    }
    
    private lazy var restInfoView = RestInfoView(frame: .zero, homeViewReactor: self.reactor!).then {
        $0.backgroundColor = .cardBackground
        $0.layer.cornerRadius = 20
        $0.isHidden = true
    }
    
    // MARK: - 페이징 스크롤 뷰 관련
    private lazy var pagingScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.isHidden = true
    }
    
    private lazy var pageController = UIPageControl().then {
        $0.currentPage = 0
        $0.numberOfPages = 0
        $0.hidesForSinglePage = true
        $0.isHidden = true
    }
    
    private lazy var pagingScrollContentView = UIView()
    
    // MARK: - Initializer
    init(reactor: HomeViewReactor, coordinator: HomeCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        setupUI()
    }
}

// MARK: - UI Methods
private extension HomeViewController {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        view.addSubviews(
            titleLabel,
            topTimerHStackView,
            buttonHStackView,
            routineStartCardView,
            pagingScrollView,
            pageController,
            restInfoView
        )
        
        topTimerHStackView.addArrangedSubviews(workoutTimeLabel, pauseButton)
        
        buttonHStackView.addArrangedSubviews(stopButton, forwardButton)
        
        pagingScrollView.addSubview(pagingScrollContentView)
    }
    
    func setConstraints() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartCardView.snp.top).offset(-32)
        }
        
        topTimerHStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartCardView.snp.top).offset(-32)
        }
        
        buttonHStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartCardView.snp.top).offset(-32)
        }
        
        stopButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        
        forwardButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        
        routineStartCardView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalToSuperview().multipliedBy(0.45)
        }
        
        pagingScrollView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalToSuperview().multipliedBy(0.45)
        }
        
        pagingScrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        pageController.snp.makeConstraints {
            $0.top.equalTo(routineStartCardView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        restInfoView.snp.makeConstraints {
            $0.top.equalTo(pageController.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.15)
        }
    }
    
    /// 운동 시작 시 표현되는 뷰 설정
    func showStartRoutineUI() {
        
        routineStartCardView.isHidden = true
        
        [topTimerHStackView,
         buttonHStackView,
         pageController,
         pagingScrollView,
         restInfoView].forEach {
            $0.isHidden = false
        }
        
        titleLabel.alpha = 0
    }
    
    /// 스크롤 뷰 기준으로 레이아웃 재설정
    func remakeOtherViewsWithScrollView() {
        
        titleLabel.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(pagingScrollView.snp.top).offset(-32)
        }
        
        topTimerHStackView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(pagingScrollView.snp.top).offset(-32)
        }
        
        buttonHStackView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(pagingScrollView.snp.top).offset(-32)
        }
        
        pageController.snp.remakeConstraints {
            $0.top.equalTo(pagingScrollView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: -  초기에 운동 카드뷰들 생성, 레이아웃 적용, 각 버튼 바인딩
    func configureExerciseCardViews(cardStates: [WorkoutCardState]) {
        
        // 기존 카드뷰 컨테이너 제거
        pagingCardViewContainer.forEach { $0.removeFromSuperview() }
        pagingCardViewContainer.removeAll()
        
        for (i, cardState) in cardStates.enumerated() {
            
            let cardView = HomePagingCardView(frame: .zero, index: cardState.exerciseIndex).then {
                $0.layer.cornerRadius = 20
            }
            
            // 레이아웃 설정
            pagingScrollContentView.addSubview(cardView)
            
            cardView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(cardWidth)
                $0.leading.equalToSuperview()
                    .offset(cardInset + CGFloat(i) * screenWidth)
            }
            
            // 뷰 저장하는 리스트에 append
            pagingCardViewContainer.append(cardView)
            // UI 정보 설정만 (버튼 바인딩은 별도로)
            cardView.configure(with: cardState)
        }
        
        remakeOtherViewsWithScrollView()
        
        if let lastCard = pagingCardViewContainer.last {
            pagingScrollContentView.snp.makeConstraints {
                // 첫 번째에 leading+20을 했으니 여기서 trailing+20 추가
                $0.trailing.equalTo(lastCard.snp.trailing).offset(cardInset)
            }
        }
        
        pageController.numberOfPages = cardStates.count
        
        print(pagingCardViewContainer.count)
        
        // 초기에도 애니메이션 적용되도록
        handlePageChanged()
        
        // 카드뷰 생성 후 버튼 바인딩
        if let reactor = self.reactor {
            self.bindCardViewsButton(reactor: reactor)
        }
        
    }
    
    // MARK: - 현재 운동 카드 삭제 시 레이아웃 조정, 변경된 transform 초기화, 리바인딩
    func setExerciseCardViewslayout(
        cardContainer: [HomePagingCardView],
        newPage: Int) {
            
            // hidden이 아닌 카드들만
            let visibleCards = cardContainer.filter { !$0.isHidden }
            
            for (i, cardView) in visibleCards.enumerated() {
                cardView.snp.remakeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.width.equalTo(cardWidth)
                    $0.leading.equalToSuperview()
                        .offset(cardInset + CGFloat(i) * screenWidth)
                }
                UIView.performWithoutAnimation {
                    cardView.transform = .identity
                    cardView.alpha = 1
                }
            }
            
            pagingScrollContentView.snp.remakeConstraints {
                $0.height.equalToSuperview()
                $0.horizontalEdges.equalToSuperview()
                
                if visibleCards.last != visibleCards.first {
                    $0.width.equalToSuperview().multipliedBy(visibleCards.count)
                } else {
                    $0.width.equalToSuperview()
                }
            }
            
            // 페이지 업데이트
            print("변경 전 - previousPage: \(self.previousPage), currentPage: \(self.currentPage) ")
            
            self.previousPage = newPage
            self.currentPage = newPage
            self.pageController.currentPage = newPage
            self.pageController.numberOfPages = visibleCards.count
            
            print("변경 후 - previousPage: \(self.previousPage), currentPage: \(self.currentPage) ")
            
            // 현재 페이지 업데이트 후 offsetX 조정
            let offsetX = CGFloat(newPage) * UIScreen.main.bounds.width
            self.pagingScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
            
            // 카드 재정렬 후 버튼 바인딩 재설정 (약간의 지연 추가)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self, let reactor = self.reactor else { return }
                print("🔄 레이아웃 재설정 후 버튼 바인딩 재실행")
                self.bindCardViewsButton(reactor: reactor)
            }
            
        }
    
    // MARK: - 애니메이션
    /// 페이징 시 애니메이션 및 내부 콘텐츠 offset 수정
    func handlePageChanged(newCurrentPage: Int = 0) {
        
        let previousPage = newCurrentPage - 1
        let nextPage = newCurrentPage + 1
        let offsetX = Int(UIScreen.main.bounds.width) * newCurrentPage
        
        // hidden이 아닌 카드들만
        let visibleCards = self.pagingCardViewContainer.filter { !$0.isHidden }
        
        pagingScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        // 모든 카드를 먼저 작아진 상태로 초기화
        visibleCards.forEach { card in
            UIView.performWithoutAnimation {
                card.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                card.alpha = 0.9
            }
        }
        
        // 현재 카드만 활성 상태로 설정
        let currentCard = visibleCards[newCurrentPage]
        UIView.performWithoutAnimation {
            currentCard.transform = .identity
            currentCard.alpha = 1
        }
        
        self.previousPage = self.currentPage
        self.currentPage = newCurrentPage
        self.pageController.currentPage = newCurrentPage
        self.pageController.numberOfPages = visibleCards.count
        
        print("currentPage: \(self.currentPage)")
        print("페이지 변경: \(self.previousPage) -> \(currentPage)")
        print(previousPage, newCurrentPage, nextPage)
    }
    
    // MARK: - 현재 페이지에서 visible한 카드의 실제 exerciseIndex를 반환하는 함수
    func getCurrentVisibleExerciseIndex() -> Int {
        let visibleCards = pagingCardViewContainer.filter { !$0.isHidden }
        guard visibleCards.indices.contains(currentPage) else {
            return visibleCards.first?.index ?? 0
        }
        return visibleCards[currentPage].index
    }
    
    // MARK: - Visible한 카드들만 바인딩
    func bindCardViewsButton(reactor: HomeViewReactor) {
        // visible한 카드들만 필터링
        let visibleCards = pagingCardViewContainer.filter { !$0.isHidden }
        
        print("🔄 버튼 바인딩 시작 - visible 카드 수: \(visibleCards.count)")
        
        // 각 visible 카드의 버튼 바인딩
        for cardView in visibleCards {
            // 기존 바인딩 해제 (개별적으로)
            cardView.disposeBag = DisposeBag()
            
            print("✅ 버튼 바인딩 - 카드 인덱스: \(cardView.index)")
            
            // 세트 완료 버튼
            cardView.setCompleteButton.rx.tap
                .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                .map { Reactor.Action.setCompleteButtonClicked(at: cardView.index) }
                .bind(onNext: { action in
                    print("세트 완료 버튼 탭 감지 - index: \(cardView.index)")
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        cardView.setCompleteButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            cardView.setCompleteButton.transform = .identity
                        }
                    })
                    //                        print("🚀 Reactor로 세트 완료 액션 전송: \(action)")
                    reactor.action.onNext(action)
                })
                .disposed(by: cardView.disposeBag)
            
            // 휴식 재생/일시정지 버튼
            cardView.restPlayPauseButton.rx.tap
                .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                .bind { [weak cardView] in
                    guard let cardView else { return }
                    print("휴식 버튼 탭 감지 - index: \(cardView.index)")
                    cardView.restPlayPauseButton.isSelected.toggle()
                    reactor.action.onNext(.restPauseButtonClicked)
                }
                .disposed(by: cardView.disposeBag)
            
            // 루틴 편집 및 메모 버튼
            cardView.editButton.rx.tap
                .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                .map { Reactor.Action.editAndMemoViewPresented(at: cardView.index) }
                .bind(onNext: { [weak self] action in
                    guard let self else { return }
                    self.coordinator?.presentEditAndMemoView()
                    reactor.action.onNext(action)
                })
                .disposed(by: disposeBag)
            
            // 해당 페이지 운동 종목 버튼
            cardView.weightRepsButton.rx.tap
                .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                .map { Reactor.Action.weightRepsButtonClicked(at: cardView.index) }
                .bind { [weak self] action in
                    guard let self else { return }
                    
                    // 클릭 애니메이션
                    UIView.animate(withDuration: 0.1, animations: {
                        cardView.weightRepsButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            cardView.weightRepsButton.transform = .identity
                        }
                    })
                    reactor.action.onNext(action)
                    self.coordinator?.presentEditExerciseView(routineName: "")
                }
                .disposed(by: disposeBag)
                
                // 휴식 재생/일시정지 버튼
                cardView.restPlayPauseButton.rx.tap
                    .observe(on: MainScheduler.asyncInstance)
                    .throttle(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
                    .do(onNext: {
                        print("휴식 버튼 탭 감지 - index: \(cardView.index)")
                    })
                    .bind { [weak cardView] in
                        guard let cardView else { return }
                        cardView.restPlayPauseButton.isSelected.toggle()
                        reactor.action.onNext(.restPauseButtonClicked)
                    }
                    .disposed(by: cardView.disposeBag)
                
                cardView.editButton.rx.tap
                    .observe(on: MainScheduler.instance)
                    .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                    .map { Reactor.Action.editAndMemoViewPresented(at: cardView.index) }
                    .bind(onNext: { [weak self] action in
                        guard let self else { return }
                        self.coordinator?.presentEditAndMemoView()
                        reactor.action.onNext(action)
                    })
                    .disposed(by: disposeBag)
                
                cardView.weightRepsButton.rx.tap
                    .observe(on: MainScheduler.instance)
                    .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                    .map { Reactor.Action.weightRepsButtonClicked(at: cardView.index) }
                    .bind { [weak self] action in
                        guard let self else { return }

                        // 클릭 애니메이션
                        UIView.animate(withDuration: 0.1, animations: {
                            cardView.weightRepsButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                        }, completion: { _ in
                            UIView.animate(withDuration: 0.1) {
                                cardView.weightRepsButton.transform = .identity
                            }
                        })
                        reactor.action.onNext(action)
                        self.coordinator?.presentEditExerciseView(routineName: "")
                    }
                    .disposed(by: disposeBag)
            }
            print("✅ 버튼 바인딩 완료 - \(visibleCards)")
    }
}

// MARK: - Reactor Binding
extension HomeViewController {
    func bind(reactor: HomeViewReactor) {
        
        print(#function)
        
        // MARK: - Action
        // 루틴 시작 버튼 클릭 시
        routineStartCardView.routineSelectButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.routineSelected }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pauseButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.workoutPauseButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 수정: forwardButton 클릭 시 현재 visible한 카드의 실제 exerciseIndex 사용
        forwardButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { [weak self] in
                guard let self = self else {
                    return Reactor.Action.forwardButtonClicked(at: 0)
                }
                // 현재 visible한 카드들의 index 받아온 후 forward
                let currentExerciseIndex = self.getCurrentVisibleExerciseIndex()
                return Reactor.Action.forwardButtonClicked(at: currentExerciseIndex)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        stopButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.stopButtonClicked }
            .bind(onNext: { [weak self] stop in
                guard let self else { return }
                // 팝업 창에서 종료 버튼을 누를 때에만 액션 실행
                self.coordinator?.popUpEndWorkoutAlert {
                    reactor.action.onNext(stop(true))
                    return reactor.currentState.workoutSummary
                }
            })
            .disposed(by: disposeBag)
        
        // MARK: - 페이징 관련
        // 스크롤의 감속이 끝났을 때 페이징
        pagingScrollView.rx.didEndDecelerating
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                // scrollView 내부 콘텐트가 수평으로 얼마나 스크롤 됐는지 / scrollView가 화면에 차지하는 너비
                let newPage = Int(round(pagingScrollView.contentOffset.x / pagingScrollView.frame.width))
                return newPage
            }
            .distinctUntilChanged()
            .do(onNext: { [weak self] newPage in
                guard let self else { return }
                print("🔍 변경된 페이지: \(newPage)")
                // 페이지가 변경 되었을 때만 조정
                if newPage != previousPage {
                    handlePageChanged(newCurrentPage: newPage)
                    // 수정: visible한 카드의 실제 exerciseIndex를 사용하여 pageChanged 액션 전송
                    let actualExerciseIndex = self.getCurrentVisibleExerciseIndex()
                    reactor.action.onNext(.pageChanged(to: actualExerciseIndex))
                }
            })
            .bind(to: pageController.rx.currentPage)
            .disposed(by: disposeBag)
        
        
        // 페이징이 되었을 시 동작 (페이지 컨트롤 클릭 시 대응)
        // 기본적으로 페이지 컨트롤 클릭 시 페이지 값이 변경되어 .valueChaned로 구현
        pageController.rx.controlEvent(.valueChanged)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                let currentPage = self.pageController.currentPage
                return currentPage
            }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] newPage in
                guard let self else { return }
                self.handlePageChanged(newCurrentPage: newPage)
                // 현재 visible한 카드들의 index 업데이트
                let actualExerciseIndex = self.getCurrentVisibleExerciseIndex()
                reactor.action.onNext(.pageChanged(to: actualExerciseIndex))
            })
            .disposed(by: disposeBag)
        
        
        // MARK: - State
        // 초기 뷰 현재 날짜 표시
        reactor.state.map { $0.isWorkingout }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .filter { !$0 }
            .bind { [weak self] _ in
                guard let self else { return }
                self.routineStartCardView.todayDateLabel.text = reactor.currentState.date.toDateLabel()
            }.disposed(by: disposeBag)
        
        // 운동 시작 시 동작
        reactor.state.map { $0.isWorkingout }
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .map { _ -> [WorkoutCardState] in
                // 백그라운드에서 데이터 준비
                return reactor.currentState.workoutCardStates
            }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] cardStates in
                guard let self else { return }
                print("--- 운동시작 ---")
                self.showStartRoutineUI()
                self.configureExerciseCardViews(cardStates: cardStates)
            }).disposed(by: disposeBag)
        
        // 운동 시간 업데이트
        reactor.state.map { $0.isWorkingout }
            .observe(on: MainScheduler.instance)
            .filter { $0 }
            .bind(onNext: { [weak self] isWorkingout in
                guard let self else { return }
                
                self.workoutTimeLabel.text = reactor.currentState.workoutTime.toWorkOutTimeLabel()
                
            }).disposed(by: disposeBag)
        
        // 휴식 중 여부에 따라 뷰 표현 전환
        reactor.state.map { ($0.restTime, $0.isResting) }
            .distinctUntilChanged { $0 == $1 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] restTime, isResting in
                guard let self else { return }
                
                self.restInfoView.restTimeLabel.text = Int(restTime).toRestTimeLabel()
                
                if isResting {
                    self.pagingCardViewContainer.forEach {
                        $0.showRestUI()
                        self.restInfoView.showWaterInfo()
                    }
                } else {
                    self.pagingCardViewContainer.forEach {
                        $0.showExerciseUI()
                    }
                    self.restInfoView.showRestInfo()
                }
            }.disposed(by: disposeBag)
        
        // TODO: 추후에 리팩토링
        // 휴식일때 휴식 프로그레스바 및 휴식시간 설정
        Observable.combineLatest(
            reactor.state.map { $0.isResting },
            reactor.state.map { $0.currentExerciseIndex },
            reactor.state.map { $0.restTime },
            reactor.state.map { $0.restSecondsRemaining },
            reactor.state.map { $0.restStartTime },
            reactor.state.map { $0.isRestTimerStopped }
        )
        .filter { !$5 }
        .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
        .map { [weak self] (restData: (Bool, Int, Float, Float, Float?, Bool)) -> [(Int, Float, String, Bool)] in
            guard let self else { return [] }
            
            let (isResting, _, restTime, restSecondsRemaining, restStartTime, _) = restData
            
            // 백그라운드에서 계산
            return self.pagingCardViewContainer.enumerated().compactMap { index, cardView in
                guard let totalRestTime = restStartTime else {
                    return (cardView.index, 0.0, Int(0).toRestTimeLabel(), false)
                }
                
                if isResting && restTime >= 0 && restSecondsRemaining >= 0 {
                    let elapsed = totalRestTime - restSecondsRemaining
                    let progress = max(min(elapsed / Float(totalRestTime), 1), 0)
                    let timeText = Int(restSecondsRemaining).toRestTimeLabel()
                    return (cardView.index, progress, timeText, true)
                } else {
                    let timeText = Int(restStartTime ?? 0).toRestTimeLabel()
                    return (cardView.index, 0.0, timeText, false)
                }
            }
        }
        .observe(on: MainScheduler.instance)
        .bind(onNext: { [weak self] calculatedData in
            guard let self else { return }
            
            // 메인 스레드에서 UI 업데이트
            calculatedData.forEach { (cardIndex, progress, timeText, isResting) in
                guard let cardView = self.pagingCardViewContainer.first(where: { $0.index == cardIndex }) else { return }
                
                let cardState = reactor.currentState.workoutCardStates[cardIndex]
                
                if isResting {
                    cardView.restProgressBar.setProgress(progress, animated: true)
                    cardView.remainingRestTimeLabel.text = timeText
                    cardView.showRestUI()
                    self.restInfoView.showWaterInfo()
                } else {
                    cardView.restProgressBar.setProgress(progress, animated: false)
                    cardView.remainingRestTimeLabel.text = timeText
                    cardView.configure(with: cardState)
                    cardView.showExerciseUI()
                    self.restInfoView.showRestInfo()
                }
            }
        })
        .disposed(by: disposeBag)
        
        // 중지 시 휴식 버튼, 프로그레스바 동작 관련
        reactor.state.map { ($0.isRestPaused, $0.isWorkoutPaused) }
            .distinctUntilChanged { $0 == $1 }
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] isRestPaused, isWorkoutPaused in
                guard let self else { return }
                
                self.pagingCardViewContainer.forEach {
                    if isRestPaused || isWorkoutPaused {
                        $0.restPlayPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                        // 정지처럼 보이게
                        let currentProgress = $0.restProgressBar.progress
                        $0.restProgressBar.setProgress(currentProgress, animated: false)
                    } else {
                        $0.restPlayPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                        // 다시 재생 - 현재 시간 기반 비율로 애니메이션 적용
                        let cardIndex = $0.index
                        let state = reactor.currentState
                        guard state.currentExerciseIndex == cardIndex,
                              state.isResting,
                              let totalRest = state.restStartTime,
                              totalRest > 0 else { return }
                        
                        let elapsed = Float(totalRest) - Float(state.restSecondsRemaining)
                        let progress = max(min(elapsed / Float(totalRest), 1), 0)
                        $0.restProgressBar.setProgress(progress, animated: true)
                    }
                }
            }.disposed(by: disposeBag)
        
        // 운동 중지 시
        reactor.state.map { $0.isWorkoutPaused }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { view, isWorkoutPaused in
                let workoutButtonImageName: String = isWorkoutPaused ? "play.fill" : "pause.fill"
                view.pauseButton.setImage(UIImage(systemName: workoutButtonImageName), for: .normal)
            }.disposed(by: disposeBag)
        
        // MARK: - 모든 세트 완료 시 카드 삭제 및 레이아웃 재설정
        // TODO: - 추후에 리팩토링
        reactor.state
            .map { $0.currentExerciseAllSetsCompleted }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .filter { $0 }
            .withLatestFrom(
                reactor.state.map { $0.currentExerciseIndex }
            )
            .bind(onNext: { [weak self] exerciseIndex in
                guard let self else { return }
                
                // 삭제할 카드 찾기 (exerciseIndex 기준)
                guard let cardToHideIndex = self.pagingCardViewContainer.firstIndex(where: { $0.index == exerciseIndex }) else {
                    print("⚠️ 삭제할 카드를 찾을 수 없습니다. exerciseIndex: \(exerciseIndex)")
                    return
                }
                
                var newPage = self.currentPage
                
                // 현재 카드의 인덱스가 유효한지 확인
                if self.pagingCardViewContainer.indices.contains(cardToHideIndex) {
                    
                    let currentCard = self.pagingCardViewContainer[cardToHideIndex]
                    
                    // 다음 페이지로 이동할지, 이전 페이지로 이동할지 결정
                    let visibleCardsBeforeHiding = self.pagingCardViewContainer.filter { !$0.isHidden }
                    let currentVisibleIndex = visibleCardsBeforeHiding.firstIndex(where: { $0.index == exerciseIndex }) ?? 0
                    
                    // 마지막 카드가 아니면 현재 위치 유지 (다음 카드로 자동 이동)
                    // 마지막 카드면 이전 카드로 이동
                    if currentVisibleIndex >= visibleCardsBeforeHiding.count - 1 {
                        // 마지막 카드인 경우, 이전 페이지로
                        newPage = max(0, self.currentPage - 1)
                    } else {
                        // 마지막이 아닌 경우, 현재 페이지 유지 (다음 카드가 현재 위치로 이동)
                        newPage = self.currentPage
                    }
                    
                    // 현재 카드 초기화 (애니메이션 전)
                    UIView.performWithoutAnimation {
                        currentCard.transform = .identity
                        currentCard.alpha = 1
                    }
                }
                
                let hiddenView = self.pagingCardViewContainer[cardToHideIndex]
                
                // 애니메이션 실행 후 끝나면 hidden
                UIView.animate(withDuration: 0.3, animations: {
                    hiddenView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                    hiddenView.alpha = 0.0
                }) { _ in
                    
                    hiddenView.isHidden = true
                    
                    // 모든 카드가 완료된 경우 체크
                    let visibleCards = self.pagingCardViewContainer.filter { !$0.isHidden }
                    if visibleCards.isEmpty {
                        print("🎉 모든 운동 완료!")
                        
                        self.coordinator?.popUpEndWorkoutAlert {
                            reactor.action.onNext(.stopButtonClicked(isEnded: true))
                            return reactor.currentState.workoutSummary
                        }
                    }
                    
                    // newPage가 유효한 범위 내에 있는지 확인
                    let finalNewPage = min(newPage, visibleCards.count - 1)
                    
                    print("💻 finalNewPage: \(finalNewPage), stateIndex: \(reactor.currentState.currentExerciseIndex)")
                    
                    // 나머지 카드 뷰 레이아웃 재조정
                    self.setExerciseCardViewslayout(
                        cardContainer: self.pagingCardViewContainer,
                        newPage: finalNewPage
                    )
                    
                    // 새로운 현재 운동의 exerciseIndex를 Reactor에 알림
                    if visibleCards.indices.contains(finalNewPage) {
                        let newExerciseIndex = visibleCards[finalNewPage].index
                        reactor.action.onNext(.pageChanged(to: newExerciseIndex))
                    }
                }
                print("카드 뷰 개수: \(self.pagingCardViewContainer.count)")
            }).disposed(by: disposeBag)
        
        // MARK: - LiveActivity 관련
        reactor.state.map { ($0.isWorkingout, $0.forLiveActivity) }
            .distinctUntilChanged { $0 == $1 }
            .observe(on: MainScheduler.instance)
            .bind { (state: (Bool, WorkoutDataForLiveActivity)) in
                                 
                let (isWorkingout, data) = state
                                 
                let contentState = data
            
                if isWorkingout {
                    LiveActivityService.shared.start(with: contentState)
                } else {
                    LiveActivityService.shared.stop()
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.forLiveActivity }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { data in
                let contentState = HowManySetWidgetAttributes.ContentState.init(
                    workoutTime: data.workoutTime,
                    isWorkingout: data.isWorkingout,
                    exerciseName: data.exerciseName,
                    exerciseInfo: data.exerciseInfo,
                    isResting: data.isResting,
                    restSecondsRemaining: Int(data.restSecondsRemaining),
                    isRestPaused: data.isRestPaused,
                    currentSet: data.currentSet,
                    totalSet: data.totalSet
                )
                LiveActivityService.shared.update(state: contentState)
            }
            .disposed(by: disposeBag)
    }//bind
}


// MARK: - LiveActivity Notification Setting
private extension HomeViewController {
    
    func setLiveActivityNotifications() {
        
        // 세트 완료
        NotificationCenter.default.addObserver(
            forName: .setCompletedFromLiveActivity,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            let index = (notification.userInfo?["index"] as? Int) ?? 0
            reactor.action.onNext(.setCompleteButtonClicked(at: index))
        }
        
        // 운동 종료
        NotificationCenter.default.addObserver(
            forName: .stopWorkoutFromLiveActivity,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            self.coordinator?.popUpEndWorkoutAlert {
                reactor.action.onNext(.stopButtonClicked(isEnded: true))
                return reactor.currentState.workoutSummary
            }
        }
        
        // 휴식 스킵
        NotificationCenter.default.addObserver(
            forName: .skipRestFromLiveActivity,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            let index = (notification.userInfo?["index"] as? Int) ?? 0
            reactor.action.onNext(.forwardButtonClicked(at: index))
        }
        
        // 휴식 정지/재개
        NotificationCenter.default.addObserver(
            forName: .playAndPauseRestFromLiveActivity,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            let index = (notification.userInfo?["index"] as? Int) ?? 0
            reactor.action.onNext(.restPauseButtonClicked(at: index))
        }
    }
}
