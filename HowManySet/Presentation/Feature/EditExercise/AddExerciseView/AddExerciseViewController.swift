//
//  EditExcerciseViewController.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

/// 운동 루틴 편집 화면을 담당하는 뷰 컨트롤러입니다.
///
/// 주요 기능:
/// - 운동 이름 입력
/// - 세트(중량/횟수) 편집
/// - 운동 항목 추가 및 루틴 저장
/// - 유효성 검증 실패 시 Alert 표시
final class AddExerciseViewController: UIViewController, View {
    
    typealias Reactor = AddExerciseViewReactor
    
    // MARK: - Properties
    
    /// Rx 리소스 해제를 위한 DisposeBag입니다.
    var disposeBag = DisposeBag()
    
    var onDismiss: (() -> Void)?
    
    // MARK: - UI Components
    
    /// 전체 화면을 스크롤 가능하게 만드는 스크롤 뷰입니다.
    private let scrollView = UIScrollView()
    
    /// 운동명을 입력하는 헤더 뷰입니다.
    private let headerView = EditExerciseHeaderView()
    
    /// 헤더 하단 구분선입니다.
    private let headerBorderLineView = UIView().then {
        $0.backgroundColor = .systemGray3
    }
    
    /// 세트 정보를 입력받는 콘텐츠 뷰입니다.
    private let contentView = EditExerciseContentView()
    
    /// 콘텐츠 하단 구분선입니다.
    private let contentBorderLineView = UIView().then {
        $0.backgroundColor = .systemGray3
    }
    
    /// 현재까지 저장된 운동 리스트를 보여주는 뷰입니다.
    private let currentView = EditExerciseCurrentStackView()
    
    /// 운동 추가 및 저장 버튼을 포함하는 하단 푸터 뷰입니다.
    private let footerView = AddExerciseFooterView()
    
    // MARK: - Initializer
    
    /// 리액터를 주입받아 초기화합니다.
    /// - Parameter reactor: 운동 편집 기능을 제어하는 Reactor
    init(reactor: AddExerciseViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    /// 스토리보드 초기화는 지원하지 않습니다.
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    /// 뷰가 로드되었을 때 호출됩니다.
    /// UI 구성 및 레이아웃을 설정합니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
    // MARK: - Binding
    
    /// 리액터 바인딩을 통해 View와 Reactor를 연결합니다.
    ///
    /// 버튼 탭, 입력값 변경, 상태 변화에 따른 Alert 및 화면 dismiss 처리를 수행합니다.
    func bind(reactor: AddExerciseViewReactor) {
        
        // 운동 추가 버튼 탭
        footerView.addExcerciseButtonTapped
            .map { Reactor.Action.addExcerciseButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 루틴 저장 버튼 탭
        footerView.saveRoutineButtonTapped
            .map { Reactor.Action.saveRoutineButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 운동 이름 입력
        headerView.exerciseNameRelay
            .map { Reactor.Action.changeExerciseName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 단위 선택 변경
        contentView.unitSelectionRelay
            .map { Reactor.Action.changeUnit($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 세트 정보 변경
        contentView.excerciseInfoRelay
            .map { Reactor.Action.changeExcerciseWeightSet($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false

        view.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .bind { [weak self] _ in
                guard let self else { return }
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        // 운동 항목이 추가되었을 때 현재 뷰에 반영
        reactor.state
            .map { $0.currentRoutine.workouts }
            .distinctUntilChanged()
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, workouts in
                guard let workout = workouts.last else { return }
                owner.currentView.addExcercise(workout: workout)
            }
            .disposed(by: disposeBag)
        
        // Alert 표시 (저장 성공/실패, 유효성 실패 등)
        reactor.alertRelay
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { (owner: AddExerciseViewController, alert) in
                switch alert {
                case .success:
                    owner.showToast(x: owner.scrollView.contentOffset.x, y: owner.scrollView.contentOffset.y, message: "운동이 추가되었어요!")
                    owner.headerView.returnInitialState()
                    owner.contentView.returnInitialState()
                case .workoutNameEmpty:
                    owner.present(owner.defaultAlert(title: "오류", message: "운동 이름을 입력해주세요."), animated: true)
                case .workoutEmpty:
                    owner.present(owner.defaultAlert(title: "오류", message: "현재 저장된 운동 항목이 없습니다."), animated: true)
                case .workoutInvalidCharacters:
                    owner.present(owner.defaultAlert(title: "오류", message: "운동 세트와 개수를 입력해주세요."), animated: true)
                case .workoutNameTooLong:
                    owner.present(owner.defaultAlert(title: "오류", message: "운동 이름이 너무 길어요."), animated: true)
                case .workoutNameTooShort:
                    owner.present(owner.defaultAlert(title: "오류", message: "운동 이름이 너무 짧아요."), animated: true)
                case .workoutContainsZero:
                    owner.present(owner.defaultAlert(title: "오류", message: "0은 입력할 수 없습니다."), animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        // 저장 후 화면 닫기
        reactor.dismissRelay
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        // MARK: - 홈 화면 데이터 연동
        reactor.state
            .map { $0.workoutStateForEdit }
            .filter { $0 != nil }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] workout in
                guard let self, let workout else { return }
                let name = workout.currentExcerciseName
                let sets = workout.currentWeightSet
                self.headerView.configure(with: name)
                self.contentView.configureSets(with: sets)
            }
            .disposed(by: disposeBag)
        
    }
}

// MARK: - UI Layout Methods

private extension AddExerciseViewController {
    
    /// 전체 UI 구성 흐름을 설정합니다.
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
    }
    
    /// 기본 배경색 등 외형을 설정합니다.
    func setAppearance() {
        view.backgroundColor = .background
    }
    
    /// 서브뷰들을 뷰 계층에 추가합니다.
    func setViewHierarchy() {
        scrollView.addSubviews(
            headerView,
            headerBorderLineView,
            contentView,
            contentBorderLineView,
            currentView
        )
        view.addSubviews(scrollView, footerView)
    }
    
    /// SnapKit을 활용한 오토레이아웃 제약 조건 설정입니다.
    func setConstraints() {
        headerView.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(112)
        }
        
        headerBorderLineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.top.equalTo(headerView.snp.bottom).offset(20)
        }
        
        contentView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(headerBorderLineView.snp.bottom).offset(20)
        }
        
        contentBorderLineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.top.equalTo(contentView.snp.bottom).offset(20)
        }
        
        currentView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(contentBorderLineView.snp.bottom).offset(32)
            $0.bottom.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(footerView.snp.top)
        }
        
        footerView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(92)
        }
    }
}

extension AddExerciseViewController {
    func setInitialUIState() {
        contentView.setInitialState()
    }
}
