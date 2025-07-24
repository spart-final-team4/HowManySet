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
    
    var disposeBag = DisposeBag()
    
    /// HomePagingCardView들을 저장하는 List
    private var pagingCardViewContainer = [HomePagingCardView]()
    
    private var currentPage = 0
    private var previousPage = 0
  
    // MARK: - UI Components
    lazy var homeView = HomeView(frame: .zero, reactor: self.reactor!)
    
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
        view.addSubview(homeView)
    }
    
    func setConstraints() {
        homeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
            homeView.pagingScrollContentView.addSubview(cardView)
            
            cardView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(homeView.cardWidth)
                $0.leading.equalToSuperview()
                    .offset(homeView.cardInset + CGFloat(i) * homeView.screenWidth)
            }
            // 뷰 저장하는 리스트에 append
            pagingCardViewContainer.append(cardView)
            // UI 정보 설정만 (버튼 바인딩은 별도로)
            cardView.configure(with: cardState)
        }
        
        homeView.remakeOtherViewsWithScrollView()
        
        if let lastCard = pagingCardViewContainer.last {
            homeView.pagingScrollContentView.snp.makeConstraints {
                // 첫 번째에 leading+20을 했으니 여기서 trailing+20 추가
                $0.trailing.equalTo(lastCard.snp.trailing).offset(homeView.cardInset)
            }
        }
        homeView.pageController.numberOfPages = cardStates.count
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
                    $0.width.equalTo(homeView.cardWidth)
                    $0.leading.equalToSuperview()
                        .offset(homeView.cardInset + CGFloat(i) * homeView.screenWidth)
                }
                UIView.performWithoutAnimation {
                    cardView.transform = .identity
                    cardView.alpha = 1
                }
            }
            
            homeView.pagingScrollContentView.snp.remakeConstraints {
                $0.height.equalToSuperview()
                $0.horizontalEdges.equalToSuperview()
                
                if visibleCards.last != visibleCards.first {
                    $0.width.equalToSuperview().multipliedBy(visibleCards.count)
                } else {
                    $0.width.equalToSuperview()
                }
            }
            
            // 페이지 업데이트
            self.previousPage = newPage
            self.currentPage = newPage
            self.homeView.pageController.currentPage = newPage
            self.homeView.pageController.numberOfPages = visibleCards.count
            
            // 현재 페이지 업데이트 후 offsetX 조정
            let offsetX = CGFloat(newPage) * UIScreen.main.bounds.width
            self.homeView.pagingScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
            
            // 카드 재정렬 후 버튼 바인딩 재설정 (약간의 지연 추가)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self, let reactor = self.reactor else { return }
                self.bindCardViewsButton(reactor: reactor)
            }
            
        }
    
    // MARK: - 애니메이션
    /// 페이징 시 애니메이션 및 내부 콘텐츠 offset 수정
    func handlePageChanged(newCurrentPage: Int = 0) {
        let offsetX = Int(UIScreen.main.bounds.width) * newCurrentPage
        
        // hidden이 아닌 카드들만
        let visibleCards = self.pagingCardViewContainer.filter { !$0.isHidden }
        
        homeView.pagingScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        // 애니메이션을 통한 카드 상태 변경
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
            // 모든 카드를 먼저 작아진 상태로 애니메이션
            visibleCards.enumerated().forEach { index, card in
                if index == newCurrentPage {
                    card.transform = .identity
                    card.alpha = 1.0
                } else {
                    card.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    card.alpha = 0.9
                }
            }
        })
        
        self.previousPage = newCurrentPage
        self.currentPage = newCurrentPage
        self.homeView.pageController.currentPage = newCurrentPage
        self.homeView.pageController.numberOfPages = visibleCards.count
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
        let visibleCards = self.pagingCardViewContainer.filter { !$0.isHidden }
        
        // 각 visible 카드의 버튼 바인딩
        for cardView in visibleCards {
            // 기존 바인딩 해제 (개별적으로)
            cardView.disposeBag = DisposeBag()
            
            // 세트 완료 버튼
            cardView.setCompleteButton.rx.tap
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .do(onNext: {
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                        cardView.setCompleteButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                            cardView.setCompleteButton.transform = .identity
                        })
                    })
                })
                .map { Reactor.Action.setCompleteButtonClicked(at: cardView.index) }
                .bind(to: reactor.action)
                .disposed(by: cardView.disposeBag)
            
            // 루틴 편집 및 메모 버튼
            cardView.editButton.rx.tap
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .do(onNext: { [weak self] _ in
                    guard let self else { return }
                    self.coordinator?.presentEditAndMemoView()
                })
                .map { Reactor.Action.editAndMemoViewPresented(at: cardView.index) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            // MARK: - 운동 중 운동 편집
            // 해당 페이지 운동 종목 버튼
            cardView.weightRepsButton.rx.tap
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .do(onNext: {
                    // 클릭 애니메이션
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                        cardView.weightRepsButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                            cardView.weightRepsButton.transform = .identity
                        })
                    })
                })
                .bind(onNext: { [weak self] _ in
                    guard let self else { return }
                    self.coordinator?.presentEditExerciseView(
                        workout: reactor.currentState.currentWorkoutData
                    )
                })
                .disposed(by: disposeBag)
            
            // 휴식 재생/일시정지 버튼
            cardView.restPlayPauseButton.rx.tap
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .map { Reactor.Action.restPauseButtonClicked }
                .bind(to: reactor.action)
                .disposed(by: cardView.disposeBag)
        }
    }
}

// MARK: - Reactor Binding
extension HomeViewController {
    func bind(reactor: HomeViewReactor) {
        
        // MARK: - Action
        // 운동 중지 버튼 클릭 시
        homeView.pauseButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.workoutPauseButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 수정: forwardButton 클릭 시 현재 visible한 카드의 실제 exerciseIndex 사용
        homeView.forwardButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { [weak self] in
                guard let self else {
                    return Reactor.Action.forwardButtonClicked(at: 0)
                }
                // 현재 visible한 카드들 index 받아온 후 forward
                let currentExerciseIndex = self.getCurrentVisibleExerciseIndex()
                return Reactor.Action.forwardButtonClicked(at: currentExerciseIndex)
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 운동 종료 버튼 클릭 시
        homeView.stopButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.popUpEndWorkoutAlert(
                    onConfirm: {
                        reactor.action.onNext(.stopButtonClicked)
                        LiveActivityService.shared.stop() // 라이브 액티비티 종료
                        return reactor.currentState.workoutSummary
                    },
                    onCancel: {
                        return nil
                    }
                )
            })
            .disposed(by: disposeBag)
        
        // MARK: - 페이징 관련
        // 스크롤의 감속이 끝났을 때 페이징
        homeView.pagingScrollView.rx.didEndDecelerating
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                // scrollView 내부 콘텐트가 수평으로 얼마나 스크롤 됐는지 / scrollView가 화면에 차지하는 너비
                let newPage = Int(round(homeView.pagingScrollView.contentOffset.x / homeView.pagingScrollView.frame.width))
                return newPage
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .do(onNext: { [weak self] newPage in
                guard let self else { return }
                // 페이지가 변경 되었을 때만 조정
                if newPage != previousPage {
                    handlePageChanged(newCurrentPage: newPage)
                    // 수정: visible한 카드의 실제 exerciseIndex를 사용하여 pageChanged 액션 전송
                    let actualExerciseIndex = self.getCurrentVisibleExerciseIndex()
                    reactor.action.onNext(.pageChanged(to: actualExerciseIndex))
                }
            })
            .bind(to: homeView.pageController.rx.currentPage)
            .disposed(by: disposeBag)
        
        
        // 페이징이 되었을 시 동작 (페이지 컨트롤 클릭 시 대응)
        // 기본적으로 페이지 컨트롤 클릭 시 페이지 값이 변경되어 .valueChaned로 구현
        homeView.pageController.rx.controlEvent(.valueChanged)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                let currentPage = homeView.pageController.currentPage
                return currentPage
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] newPage in
                guard let self else { return }
                self.handlePageChanged(newCurrentPage: newPage)
                // 현재 visible한 카드들의 index 업데이트
                let actualExerciseIndex = self.getCurrentVisibleExerciseIndex()
                reactor.action.onNext(.pageChanged(to: actualExerciseIndex))
            })
            .disposed(by: disposeBag)
        
        
        // MARK: - State
        // 운동 시작 시 동작
        reactor.state.map { $0.isWorkingout }
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .map { _ -> [WorkoutCardState] in
                // 백그라운드에서 데이터 준비
                return reactor.currentState.workoutCardStates
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] cardStates in
                guard let self else { return }
                self.configureExerciseCardViews(cardStates: cardStates)
            }).disposed(by: disposeBag)
        
        // 운동 시간 업데이트
        reactor.state.map { $0.isWorkingout }
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] isWorkingout in
                guard let self else { return }
                self.homeView.workoutTimeLabel.text = reactor.currentState.workoutTime.toWorkOutTimeLabel()
            }).disposed(by: disposeBag)
        
        // 휴식 중 여부에 따라 뷰 표현 전환
        Observable.combineLatest(
            reactor.state.map { $0.restTime },
            reactor.state.map { $0.isResting },
            reactor.state.map { $0.isWorkingout }
        )
        .filter { $2 }
        .distinctUntilChanged { $0 == $1 }
        .observe(on: MainScheduler.instance)
        .bind { [weak self] (data: (Float, Bool, Bool)) in
            guard let self else { return }
            let (restTime, isResting, _ ) = data
            homeView.restInfoView.restTimeLabel.text = Int(restTime).toRestTimeLabel()
            
            if isResting {
                self.pagingCardViewContainer.forEach {
                    $0.showRestUI()
                    self.homeView.restInfoView.showWaterInfo()
                }
            } else {
                self.pagingCardViewContainer.forEach {
                    $0.showExerciseUI()
                }
                self.homeView.restInfoView.showRestInfo()
            }
        }.disposed(by: disposeBag)
        
        // TODO: 추후에 리팩토링
        // 휴식일때 휴식 프로그레스바, 휴식시간 설정, 운동 카드 뷰 UI 갱신
        Observable.combineLatest(
            reactor.state.map { $0.isResting },
            reactor.state.map { $0.currentExerciseIndex },
            reactor.state.map { $0.restTime },
            reactor.state.map { $0.restRemainingTime },
            reactor.state.map { $0.restStartTime },
            reactor.state.map { $0.isRestTimerStopped }
        )
        .distinctUntilChanged { $0 == $1 }
        .observe(on: MainScheduler.instance)
        .map { [weak self] (restData: (Bool, Int, Float, Float, Float?, Bool)) -> [(Int, Float, String, Bool, Bool)] in
            guard let self else { return [] }
            
            let (isResting, _, restTime, restSecondsRemaining, restStartTime, _) = restData
            
            return self.pagingCardViewContainer.enumerated().compactMap { index, cardView in
                guard let totalRestTime = restStartTime else {
                    return (cardView.index, 0.0, Int(0).toRestTimeLabel(), false, true)
                }
                
                if isResting && restTime >= 0 && restSecondsRemaining >= 0 {
                    let elapsed = totalRestTime - restSecondsRemaining
                    let progress = max(min(elapsed / Float(totalRestTime), 1), 0)
                    let timeText = Int(restSecondsRemaining).toRestTimeLabel()
                    return (cardView.index, progress, timeText, true, false)
                } else {
                    let timeText = Int(restStartTime ?? 0).toRestTimeLabel()
                    return (cardView.index, 0.0, timeText, false, true)
                }
            }
        }
        .bind(onNext: { [weak self] calculatedData in
            guard let self else { return }
            
            calculatedData.forEach { (cardIndex, progress, timeText, isResting, isRestTimerStopped) in
                guard let cardView = self.pagingCardViewContainer.first(where: { $0.index == cardIndex }) else { return }
                
                let cardState = reactor.currentState.workoutCardStates[cardIndex]
                
                // MARK: - 변경된 운동 정보(세트 수, 무게, 횟수)들로 업데이트
                cardView.configure(with: cardState)
                
                if isResting && !isRestTimerStopped {
                    cardView.restProgressBar.setProgress(progress, animated: true)
                    cardView.remainingRestTimeLabel.text = timeText
                    cardView.showRestUI()
                    self.homeView.restInfoView.showWaterInfo()
                } else {
                    cardView.restProgressBar.setProgress(progress, animated: false)
                    cardView.remainingRestTimeLabel.text = timeText
                    cardView.showExerciseUI()
                    self.homeView.restInfoView.showRestInfo()
                }
            }
        })
        .disposed(by: disposeBag)
        
        // 중지 시 휴식 버튼, 프로그레스바 동작 관련
        reactor.state.map { ($0.isRestPaused, $0.isWorkoutPaused) }
            .distinctUntilChanged { $0 == $1 }
            .observe(on: MainScheduler.instance)
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
                              totalRest >= 0 else { return }
                        
                        let elapsed = Float(totalRest) - Float(state.restRemainingTime)
                        let progress = max(min(elapsed / Float(totalRest), 1), 0)
                        $0.restProgressBar.setProgress(progress, animated: true)
                    }
                }
            }.disposed(by: disposeBag)
        
        // 운동 중지 시
        reactor.state.map { $0.isWorkoutPaused }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind{ [weak self] isWorkoutPaused in
                guard let self else { return }
                let workoutButtonImageName: String = isWorkoutPaused ? "play.fill" : "pause.fill"
                self.homeView.pauseButton.setImage(UIImage(systemName: workoutButtonImageName), for: .normal)
            }.disposed(by: disposeBag)
        
        // MARK: - 모든 세트 완료 시 카드 삭제 및 레이아웃 재설정
        // TODO: - 추후에 리팩토링
        reactor.state
            .map { $0.currentExerciseAllSetsCompleted }
            .distinctUntilChanged()
            .filter { $0 }
            .withLatestFrom(
                reactor.state.map { $0.currentExerciseIndex }
            )
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] currentIndex in
                guard let self else { return }
                // 삭제할 카드 찾기 (exerciseIndex 기준)
                guard let cardToHideIndex = self.pagingCardViewContainer.firstIndex(
                    where: { $0.index == currentIndex }
                ) else {
                    return
                }
                
                let cardToHide = self.pagingCardViewContainer[cardToHideIndex]
                let visibleCardsBeforeHiding = self.pagingCardViewContainer.filter { !$0.isHidden }
                let maxProgress = reactor.currentState.workoutCardStates[cardToHideIndex].setProgressAmount + 1
                
                self.animateProgressBarCompletion(cardToHide, with: maxProgress) { [weak self] in
                    guard let self else { return }
                    self.animateCardDeletion(cardToHide) { [weak self] in
                        guard let self else { return }
                        // 현재 보이는 카드 중에서의 인덱스 찾기
                        guard let currentVisibleIndex = visibleCardsBeforeHiding.firstIndex(where: { $0.index == currentIndex }) else {
                            return
                        }
                        // 다음 페이지 계산
                        let newPage: Int
                        if currentVisibleIndex >= visibleCardsBeforeHiding.count - 1 {
                            // 마지막 카드인 경우, 이전 페이지로
                            newPage = max(0, currentVisibleIndex - 1)
                        } else {
                            // 마지막이 아닌 경우, 현재 페이지 유지
                            newPage = currentVisibleIndex
                        }
                        // 남은 visible 카드 확인
                        let remainingVisibleCards = self.pagingCardViewContainer.filter { !$0.isHidden }
                        // 유효한 페이지 범위로 조정
                        let finalNewPage = min(newPage, remainingVisibleCards.count - 1)
                        // 레이아웃 재조정
                        self.setExerciseCardViewslayout(
                            cardContainer: self.pagingCardViewContainer,
                            newPage: finalNewPage
                        )
                        // Reactor에 페이지 변경 알림
                        if remainingVisibleCards.indices.contains(finalNewPage) {
                            let newExerciseIndex = remainingVisibleCards[finalNewPage].index
                            if let reactor = self.reactor {
                                reactor.action.onNext(.pageChanged(to: newExerciseIndex))
                                reactor.action.onNext(.cardDeleteAnimationCompleted(oldIndex: currentIndex, nextIndex: newExerciseIndex))
                            }
                        } else if remainingVisibleCards.isEmpty {
                            // 모든 운동 완료 시
                            reactor.action.onNext(.cardDeleteAnimationCompleted(oldIndex: currentIndex, nextIndex: currentIndex))
                            // 운동 완료 처리
                            if let reactor = self.reactor {
                                self.coordinator?.popUpCompletedWorkoutAlert(onConfirm: {
                                    reactor.action.onNext(.stopButtonClicked)
                                    LiveActivityService.shared.stop() // 라이브 액티비티 종료
                                    return reactor.currentState.workoutSummary
                                }, onCancel: { [weak self] in
                                    guard let self else { return }
                                    // 계속하기 클릭 시 hidden 해제
                                    self.pagingCardViewContainer.forEach {
                                        $0.isHidden = false
                                    }
                                    self.setExerciseCardViewslayout(cardContainer: self.pagingCardViewContainer, newPage: 0)
                                })
                            }
                            return
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
        // MARK: - 운동 중 편집 시
        reactor.state.map { ($0.workoutCardStates, $0.currentExerciseIndex) }
            .map {
                let currentIndex = reactor.currentState.currentExerciseIndex
                let newCardState = $0[currentIndex]
                return (newCardState, $1)
            }
            .distinctUntilChanged { $0.0 == $1.0 }
            .skip(1)
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] (newCardState, index) in
                guard let self else { return }
                self.pagingCardViewContainer[index].configure(with: newCardState, isEdited: true)
            })
            .disposed(by: disposeBag)
        
        // MARK: - LiveActivity 관련
        // contentState 캐싱
        var cachedContentState: HowManySetWidgetAttributes.ContentState?
        
        // LiveActivity start/stop
        reactor.state.map { ($0.isWorkingout, $0.forLiveActivity) }
            .distinctUntilChanged { $0.0 == $1.0 }
            .filter { $0.0 }
            .observe(on: MainScheduler.instance)
            .bind { (state: (Bool, WorkoutDataForLiveActivity)) in
                let (isWorkingout, data) = state
                if isWorkingout {
                    LiveActivityService.shared.start(with: data)
                    cachedContentState = .init(from: data)
                } else {
                    LiveActivityService.shared.stop()
                    cachedContentState = nil
                }
            }
            .disposed(by: disposeBag)
        
        // LiveActivity isResting, isRemaining 제외한 요소들 업데이트
        reactor.state.map { $0.forLiveActivity }
            .distinctUntilChanged { $0.isEqualExcludingRestStates(to: $1) }
            .map { data in
                guard let cached = cachedContentState else {
                    let data = reactor.currentState.forLiveActivity
                    let newState = HowManySetWidgetAttributes.ContentState.init(from: data)
                    cachedContentState = newState
                    return newState
                }
                let updated = cached.updateOtherStates(from: data)
                cachedContentState = updated
                return updated
            }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { contentState in
                LiveActivityService.shared.update(state: contentState)
            })
            .disposed(by: disposeBag)
        
        
        Observable.combineLatest(
            reactor.state.map { $0.isResting },
            reactor.state.map { $0.restRemainingTime }
        )
        .distinctUntilChanged { $0 == $1 }
        .map { restInfo -> HowManySetWidgetAttributes.ContentState in
            let (isResting, restRemaining) = restInfo
            guard let cached = cachedContentState else {
                let data = reactor.currentState.forLiveActivity
                let newState = HowManySetWidgetAttributes.ContentState.init(from: data)
                cachedContentState = newState
                return newState
            }
            let updated = cached.updateRestInfo(isResting, restRemaining)
            cachedContentState = updated
            return updated
        }
        .debounce(.milliseconds(100), scheduler: MainScheduler.instance) 
        .bind(onNext: { contentState in
            LiveActivityService.shared.update(state: contentState)
        })
        .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .bind { _ in
                reactor.action.onNext(.adjustWorkoutTimeOnForeground)
                reactor.action.onNext(.adjustRestRemainingTimeOnForeground)
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .observe(on: MainScheduler.instance)
            .bind { _ in
                if reactor.currentState.isResting {
                    reactor.action.onNext(.didEnterBackgroundWhileResting)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.playAndPauseRestEvent)
            .observe(on: MainScheduler.instance)
            .bind { notification in
                LiveActivityAppGroupEventBridge.shared.checkPlayAndPauseRestEvent { index in
                    reactor.action.onNext(.restPauseButtonClicked)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.setCompleteEvent)
            .observe(on: MainScheduler.instance)
            .bind { notification in
                LiveActivityAppGroupEventBridge.shared.checkSetCompleteEvent { index in
                    reactor.action.onNext(.setCompleteButtonClicked(at: index))
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.skipEvent)
            .observe(on: MainScheduler.instance)
            .bind { notification in
                LiveActivityAppGroupEventBridge.shared.checkSkipRestEvent { index in
                    reactor.action.onNext(.forwardButtonClicked(at: index))
                }
            }
            .disposed(by: disposeBag)
        
    }//bind
}


// MARK: - 애니메이션 메서드들
private extension HomeViewController {
    
    /// 프로그레스바 완료
    func animateProgressBarCompletion(
        _ cardView: HomePagingCardView,
        with progress: Int,
        completion: @escaping () -> Void
    ) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            // 프로그레스바를 100%로
            cardView.setProgressBar.updateProgress(currentSet: progress)
        }, completion: { _ in
            completion()
        })
    }
    
    /// 카드 삭제 애니메이션
    func animateCardDeletion(_ cardView: HomePagingCardView, completion: @escaping () -> Void) {
        // 카드가 위로 사라지면서 페이드아웃
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseInOut], animations: {
            cardView.transform = CGAffineTransform(translationX: 0, y: -cardView.frame.height)
                .scaledBy(x: 0.8, y: 0.8)
            cardView.alpha = 0.1
        }, completion: { _ in
            cardView.isHidden = true
            cardView.transform = .identity
            cardView.alpha = 1
            completion()
        })
    }
}
