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
    
    private let setText = "세트"
    private let repsText = "회"
    private let homeText = "홈"
    
    var disposeBag = DisposeBag()
    
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
    
    private lazy var topRoutineInfoVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .trailing
    }
    
    private lazy var routineNameLabel = UILabel().then {
        $0.textColor = .textSecondary
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private lazy var routineNumberLabel = UILabel().then {
        $0.textColor = .textSecondary
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private lazy var routineStartCardView = HomeRoutineStartCardView().then {
        $0.layer.cornerRadius = 20
    }
    
    private lazy var pagingCardView = HomePagingCardView().then {
        $0.layer.cornerRadius = 20
        $0.isHidden = true
    }
    
    private lazy var pageController = UIPageControl().then {
        $0.currentPage = 0
        $0.numberOfPages = 5
        $0.hidesForSinglePage = true
        $0.isHidden = true
    }
    
    private lazy var buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
        $0.isHidden = true
    }
    
    private lazy var stopButton = UIButton().then {
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        $0.tintColor = .pauseButton
    }
    
    private lazy var forwardButton = UIButton().then {
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        $0.tintColor = .white
    }
    
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
            routineStartCardView,
            pageController,
            buttonHStackView,
            pagingCardView
        )
        
        topTimerHStackView.addArrangedSubviews(workoutTimeLabel, pauseButton, topRoutineInfoVStackView)
        topRoutineInfoVStackView.addArrangedSubviews(routineNameLabel, routineNumberLabel)
        buttonHStackView.addArrangedSubviews(stopButton, forwardButton)
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
        
        topRoutineInfoVStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartCardView.snp.top).offset(-32)
        }
        
        routineStartCardView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalToSuperview().multipliedBy(0.47)
        }
        
        pagingCardView.snp.makeConstraints {
            $0.edges.equalTo(routineStartCardView)
        }
        
        pageController.snp.makeConstraints {
            $0.top.equalTo(routineStartCardView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        buttonHStackView.snp.makeConstraints {
            $0.top.equalTo(pageController.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(80)
            $0.centerX.equalToSuperview()
        }
        
        stopButton.snp.makeConstraints {
            $0.width.height.equalTo(80)
        }
        
        forwardButton.snp.makeConstraints {
            $0.width.height.equalTo(80)
        }
    }
    
    func showStartRoutineUI() {
        
        routineStartCardView.isHidden = true
        pagingCardView.isHidden = false
        pagingCardView.setProgressBar.isHidden = false
        
        [topTimerHStackView, topRoutineInfoVStackView, pageController, buttonHStackView].forEach {
            $0.isHidden = false
        }
        
        titleLabel.alpha = 0
        
    }
}

// MARK: - Rx Methods
extension HomeViewController {
    func bind(reactor: HomeViewReactor) {
        
        print(#function)
        
        // MARK: - Action
        // 루틴 선택 버튼 클릭 시
        routineStartCardView.routineSelectButton.rx.tap
            .map { Reactor.Action.routineSelected }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 세트 완료 버튼 클릭 시
        pagingCardView.setCompleteButton.rx.tap
            .map { Reactor.Action.routineCompleteButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pauseButton.rx.tap
            .map { Reactor.Action.pauseButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pagingCardView.restButton1.rx.tap
            .map { Reactor.Action.rest1ButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pagingCardView.restButton2.rx.tap
            .map { Reactor.Action.rest2ButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pagingCardView.restButton3.rx.tap
            .map { Reactor.Action.rest3ButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pagingCardView.restResetButton.rx.tap
            .map { Reactor.Action.restResetButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: - State
        reactor.state.map { $0.isWorkingout }
            .distinctUntilChanged()
            .filter { $0 }
            .take(1) // 처음 true 된 시점에만 운동 초기 화면
            .bind(with: self) { view, _ in
                view.showStartRoutineUI()
            }
            .disposed(by: disposeBag)
        
        // 텍스트 등 뷰 요소 바인딩
        reactor.state.map { $0 }
            .filter { $0.isWorkingout == true }
            .bind(with: self) { (view: HomeViewController, state) in
                
                view.workoutTimeLabel.text = state.workoutTime.toWorkOutTimeLabel()
                view.routineNameLabel.text = state.workoutRoutine.name
                view.routineNumberLabel.text = "\(state.currentExerciseNumber) / \(state.totalExerciseCount)"
                
                view.pagingCardView.exerciseNameLabel.text = state.currentExerciseName
                view.pagingCardView.exerciseSetLabel.text = "\(state.currentSetNumber) / \(state.totalSetCount)"
                view.pagingCardView.currentSetLabel.text = "\(state.currentSetNumber)\(view.setText)"
                view.pagingCardView.weightLabel.text = "\(Int(state.currentWeight))\(state.currentUnit)"
                view.pagingCardView.repsLabel.text = "\(state.currentReps)\(view.repsText)"
            }
            .disposed(by: disposeBag)
        
        // setProgressBar 바인딩
        Observable.combineLatest(
            reactor.state.map { $0.currentSetNumber }.distinctUntilChanged(),
            reactor.state.map { $0.totalSetCount }.distinctUntilChanged()
        )
        .filter { currentSet, _ in currentSet == 1 } // 첫 세트일 때만
        .bind(with: self) { view, sets in
            let (_, totalSet) = sets
            view.pagingCardView.setProgressBar.setupSegments(totalSets: totalSet)
        }
        .disposed(by: disposeBag)
        
        // 휴식일때 휴식 프로그레스바 및 휴식시간 설정
        reactor.state.map { $0.isResting }
            .distinctUntilChanged()
            .bind(with: self) { view, isResting in
                if isResting {
                    view.pagingCardView.showRestUI()
                                        
                    // 남은 시간 텍스트 업데이트 (시작 시점에 맞춰)
                    view.pagingCardView.remaingRestTimeLabel.text = Int(reactor.currentState.restSecondsRemaining).toRestTimeLabel()
                } else {
                    view.pagingCardView.showExerciseUI()
                    
                    view.pagingCardView.restProgressBar.setProgress(0, animated: false)
                }
            }.disposed(by: disposeBag)
        
        // 남은 휴식 시간에 따라 휴식 프로그레스바 바인딩
        reactor.state.map { $0.restSecondsRemaining }
            .distinctUntilChanged()
            .bind(with: self) { view, restSecondsRemaining in
                if reactor.currentState.isResting {
                    let totalRestTime = reactor.currentState.restTime // 현재 전체 휴식 시간
                    
                    // restSecondsRemaining이 0보다 크고, totalRestTime이 0보다 클 때만 계산
                    if totalRestTime > 0 {
                        // 경과된 시간 = 전체 시간 - 남은 시간
                        let elapsedTime = Float(totalRestTime) - restSecondsRemaining
                        // 진행률 계산: (경과된 시간) / (전체 시간)
                        let progress = elapsedTime / Float(totalRestTime)
                        
                        // 프로그레스 바 업데이트
                        view.pagingCardView.restProgressBar.setProgress(Float(progress), animated: true)
                        
                    } else {
                        // totalRestTime이 0이거나 유효하지 않은 경우, 프로그레스 바를 0으로 설정
                        view.pagingCardView.restProgressBar.setProgress(0, animated: false)
                    }
                    
                    // 남은 시간 텍스트 업데이트
                    view.pagingCardView.remaingRestTimeLabel.text = Int(restSecondsRemaining).toRestTimeLabel()
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.setProgressAmount }
            .distinctUntilChanged()
            .bind(with: self) { view, setProgress in
                view.pagingCardView.setProgressBar.updateProgress(currentSet: setProgress)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.isWorkoutPaused }
            .bind(with: self) { view, isWorkoutPaused in
                let buttonImageName: String = isWorkoutPaused ? "play.fill" : "pause.fill"
                view.pauseButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
            }.disposed(by: disposeBag)
    }
}
