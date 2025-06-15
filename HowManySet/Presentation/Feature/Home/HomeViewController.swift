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
    
    // MARK: -  운동 카드뷰들 생성, 레이아웃 적용
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
            
            if let lastCard = visibleCards.last,
               lastCard != visibleCards.first {
                pagingScrollContentView.snp.remakeConstraints {
                    $0.leading.equalToSuperview()
                    $0.height.equalToSuperview()
                    $0.trailing.equalTo(lastCard.snp.trailing).offset(cardInset)
                }
            } else {
                pagingScrollContentView.snp.remakeConstraints {
                    $0.edges.equalToSuperview()
                    $0.height.equalToSuperview()
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
          
            // 카드 재정렬 후 버튼 바인딩 재설정
            if let reactor = self.reactor {
                bindSetCompleteButtons(reactor: reactor)
            }
            print(visibleCards.count)
        }
    
    // MARK: - Animation
    /// 페이징 시 애니메이션 및 내부 콘텐츠 offset 수정
    func handlePageChanged(currentPage: Int = 0) {
        
        let previousPage = currentPage - 1
        let nextPage = currentPage + 1
        let offsetX = Int(UIScreen.main.bounds.width) * currentPage
        
        // hidden이 아닌 카드들만
        let visibleCards = self.pagingCardViewContainer.filter { !$0.isHidden }
        
        pagingScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        // 애니메이션
        if visibleCards.indices.contains(currentPage) {
            
            let currentCard = self.pagingCardViewContainer[currentPage]
            
            UIView.performWithoutAnimation {
                currentCard.transform = .identity
                currentCard.alpha = 1
            }
        }
        
        if previousPage >= 0,
           visibleCards.indices.contains(previousPage) {
            
            let previousCard = self.pagingCardViewContainer[previousPage]
            
            UIView.performWithoutAnimation {
                previousCard.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                previousCard.alpha = 0.8
            }
        } else {
            print("⚠️ 이전 페이지 없음!")
        }
        
        if nextPage <= pagingCardViewContainer.count - 1,
           visibleCards.indices.contains(nextPage){
            
            let nextCard = self.pagingCardViewContainer[nextPage]
            
            UIView.animate(withDuration: 0.1) {
                nextCard.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                nextCard.alpha = 0.8
            }
        } else {
            print("⚠️ 다음 페이지 없음!")
        }
        
        self.previousPage = previousPage
        self.currentPage = currentPage
        self.pageController.currentPage = currentPage
        self.pageController.numberOfPages = visibleCards.count
        print("currentPage: \(self.currentPage)")
        
        print(previousPage, currentPage, nextPage)
    }
    

    /// 세트 완료 버튼을 Reactor에 바인딩
    func bindSetCompleteButtons(reactor: HomeViewReactor) {
        // Clear previous bindings
        for cardView in pagingCardViewContainer {
            cardView.disposeBag = DisposeBag()
            // Rebind button tap for current index
            cardView.setCompleteButton.rx.tap
                .map { Reactor.Action.setCompleteButtonClicked(at: cardView.index) }
                .subscribe(onNext: { reactor.action.onNext($0) })
                .disposed(by: cardView.disposeBag)
        }
    }
}

// MARK: - Reactor Binding
extension HomeViewController {
    func bind(reactor: HomeViewReactor) {
        
        print(#function)
        
        // MARK: - Action
        // 루틴 시작 버튼 클릭 시
        routineStartCardView.routineSelectButton.rx.tap
            .map { Reactor.Action.routineSelected }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pauseButton.rx.tap
            .map { Reactor.Action.workoutPauseButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        forwardButton.rx.tap
            .map {
                Reactor.Action.forwardButtonClicked(at: reactor.currentState.currentExerciseIndex)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        stopButton.rx.tap
            .map { Reactor.Action.stopButtonClicked }
            .bind(onNext: { [weak self] stop in
                guard let self else { return }
                let workoutEnded = self.coordinator?.popUpEndWorkoutAlert()
                reactor.action.onNext(stop(workoutEnded ?? false))
            })
            .disposed(by: disposeBag)
        
        // MARK: - 페이징 관련
        // 스크롤의 감속이 끝났을 때 페이징
        pagingScrollView.rx.didEndDecelerating
            .observe(on: MainScheduler.instance)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                // scrollView 내부 콘텐트가 수평으로 얼마나 스크롤 됐는지 / scrollView가 화면에 차지하는 너비
                let newPage = Int(round(pagingScrollView.contentOffset.x / pagingScrollView.frame.width))
                return newPage
            }
            .do(onNext: { [weak self] newPage in
                guard let self else { return }
                
                print("🔍 변경된 페이지: \(newPage)")
                
                // 페이지가 변경 되었을 때만 조정
                if newPage != previousPage {
                    handlePageChanged(currentPage: newPage)
                    reactor.action.onNext(.pageChanged(to: newPage))
                }
            })
            .bind(to: pageController.rx.currentPage)
            .disposed(by: disposeBag)
        
        
        // 페이징이 되었을 시 동작 (페이지 컨트롤 클릭 시 대응)
        // 기본적으로 페이지 컨트롤 클릭 시 페이지 값이 변경되어 .valueChaned로 구현
        pageController.rx.controlEvent(.valueChanged)
            .observe(on: MainScheduler.instance)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                let currentPage = self.pageController.currentPage
                return currentPage
            }
            .bind(onNext: { [weak self] newPage in
                guard let self else { return }
                self.handlePageChanged(currentPage: newPage)
                reactor.action.onNext(.pageChanged(to: newPage))
            })
            .disposed(by: disposeBag)
        
        // MARK: - State
        // 초기 뷰 현재 날짜 표시
        reactor.state.map { $0.isWorkingout }
            .filter { !$0 }
            .bind { [weak self] _ in
                guard let self else { return }
                self.routineStartCardView.todayDateLabel.text = reactor.currentState.date.toDateLabel()
            }.disposed(by: disposeBag)
        
        
        // 운동 시작 시 동작
        reactor.state.map { $0.isWorkingout }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(onNext: { [weak self]  _ in
                
                guard let self else { return }
                print("--- 운동시작 ---")
                self.showStartRoutineUI()
                
                // 내부 카드 뷰들 세팅
                self.configureExerciseCardViews(cardStates: reactor.currentState.workoutCardStates)
                
                // MARK: -  각 카드 뷰 버튼 바인딩, UI 정보 설정
                for (index, cardView) in self.pagingCardViewContainer.enumerated() {
                    
                    print("버튼 바인딩: \(index)")
                    
                    cardView.setCompleteButton.rx.tap
                        .map { Reactor.Action.setCompleteButtonClicked(at: cardView.index) }
                        .subscribe(onNext: {
                            reactor.action.onNext($0)
                        }).disposed(by: cardView.disposeBag)
                    
                    cardView.restPlayPauseButton.rx.tap
                        .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                        .bind { [weak cardView] in
                            guard let cardView else { return }
                            cardView.restPlayPauseButton.isSelected.toggle()
                            reactor.action.onNext(.restPauseButtonClicked)
                        }.disposed(by: cardView.disposeBag)
                    
                    cardView.configure(with: reactor.currentState.workoutCardStates[index])
                }
            }).disposed(by: disposeBag)
        
        // 운동 시간 업데이트
        reactor.state.map { $0.isWorkingout }
            .filter { $0 }
            .bind(onNext: { [weak self] isWorkingout in
                guard let self else { return }
                
                self.workoutTimeLabel.text = reactor.currentState.workoutTime.toWorkOutTimeLabel()
                
            }).disposed(by: disposeBag)
        
        reactor.state.map { ($0.restTime, $0.isResting) }
            .distinctUntilChanged { $0 == $1 }
            .bind { [weak self] restTime, isResting in
                guard let self else { return }
                
                self.restInfoView.restTimeLabel.text = restTime.toRestTimeLabel()
                
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
        
        // 휴식일때 휴식 프로그레스바 및 휴식시간 설정
        Observable.combineLatest(
            reactor.state.map { $0.isResting },
            reactor.state.map { $0.currentExerciseIndex },
            reactor.state.map { $0.restTime },
            reactor.state.map { $0.restSecondsRemaining },
            reactor.state.map { $0.restStartTime },
            reactor.state.map { $0.isWorkingout }
        )
        .filter { $5 }
        .bind(onNext: { [weak self]
            isResting,
            exerciseIndex,
            restTime,
            restSecondsRemaining,
            restStartTime,
            isWorkingout in
            guard let self else { return }
            
            self.pagingCardViewContainer.enumerated().forEach { index, cardView in
                
                let cardState = reactor.currentState.workoutCardStates[cardView.index]
                
                guard let totalRestTime = restStartTime, totalRestTime > 0 else {
                    cardView.restProgressBar.setProgress(0, animated: false)
                    cardView.configure(with: cardState)
                    return
                }
                
                if isResting && restTime > 0 && Int(restSecondsRemaining) > 0 {
                    
                    print("남은 휴식 시간: \(restSecondsRemaining)")
                    
                    let elapsed = Float(totalRestTime) - restSecondsRemaining
                    let progress = max(min(elapsed / Float(totalRestTime), 1), 0)
                    cardView.restProgressBar.setProgress(progress, animated: true)
                    cardView.remainingRestTimeLabel.text = Int(restSecondsRemaining).toRestTimeLabel()
                    self.restInfoView.showWaterInfo()
                    cardView.showRestUI()
                    
                } else {
                    cardView.restProgressBar.setProgress(0, animated: false)
                    cardView.configure(with: cardState)
                    cardView.showExerciseUI()
                    self.restInfoView.showRestInfo()
                }
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.isRestPaused }
            .distinctUntilChanged()
            .bind { [weak self] isRestPaused in
                guard let self else { return }
                
                self.pagingCardViewContainer.forEach {
                    if isRestPaused {
                        // 정지처럼 보이게
                        let currentProgress = $0.restProgressBar.progress
                        $0.restProgressBar.setProgress(currentProgress, animated: false)
                    } else {
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
        
        
        reactor.state.map { $0.isWorkoutPaused }
            .bind(with: self) { view, isWorkoutPaused in
                let buttonImageName: String = isWorkoutPaused ? "play.fill" : "pause.fill"
                view.pauseButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
                
                view.pagingCardViewContainer.forEach {
                    let buttonImageName: String = isWorkoutPaused ? "play.fill" : "pause.fill"
                    $0.restPlayPauseButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
                }
            }.disposed(by: disposeBag)
        
        // TODO: - 추후에 해결
        // 모든 세트 완료 시 카드 삭제 및 레이아웃 재설정
        reactor.state
            .map { $0.currentExerciseAllSetsCompleted }
            .distinctUntilChanged()        // true가 될 때만
            .filter { $0 }                 // true인 경우만
            .withLatestFrom(
                reactor.state.map { $0.currentExerciseIndex }
            )
            .bind(onNext: { [weak self] index in
                guard let self else { return }
                
                var newPage = 0
                
                if pagingCardViewContainer.indices.contains(index) {
                    
                    let currentCard = self.pagingCardViewContainer[index]
                    // 현재 카드뷰의 인덱스 가져옴 - State 인덱스와 동일해야하기에
                    
                    if self.pagingCardViewContainer.indices.contains(newPage + 1) {
                        newPage += 1
                    } else if self.pagingCardViewContainer.indices.contains(newPage - 1) {
                        newPage -= 1
                    }
                    
                    UIView.performWithoutAnimation {
                        currentCard.transform = .identity
                        currentCard.alpha = 1
                    }
                }
                
                let hiddenView = self.pagingCardViewContainer[index]
                
                // 애니메이션 실행 후 끝나면 hidden
                UIView.animate(withDuration: 0.3, animations: {
                    hiddenView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                    hiddenView.alpha = 0.0
                }) { _ in
                    
                    self.pagingCardViewContainer[index].isHidden = true
                    
                    print("💻 newPage: \(newPage), stateIndex: \(reactor.currentState.currentExerciseIndex)")
                    
                    // 나머지 카드 뷰 레이아웃 재조정
                    self.setExerciseCardViewslayout(
                        cardContainer: self.pagingCardViewContainer,
                        newPage: newPage
                    )
                    
                }
                print("카드 뷰 개수: \(self.pagingCardViewContainer.count)")
                
            })
            .disposed(by: disposeBag)
    }
}
