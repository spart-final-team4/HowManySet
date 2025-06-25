//
//  AddRoutineViewController.swift
//  HowManySet
//
//  Created by MJ Dev on 5/30/25.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa

/// 운동 루틴 편집 화면을 관리하는 뷰 컨트롤러
/// - 역할: 테이블 뷰를 통해 운동 루틴 목록을 표시하고 편집할 수 있도록 구성
/// - ReactorKit 등의 리액티브 아키텍처에서 상태 관리 객체(reactor)를 소유함
final class EditRoutineViewController: UIViewController, View {
    
    typealias Reactor = EditRoutineViewReactor
    
    var disposeBag = DisposeBag()
    
    private let startText = "시작"
    
    private let coordinator: EditRoutineCoordinatorProtocol
    
    /// 운동 루틴 리스트를 보여주는 테이블 뷰
    private lazy var tableView = EditRoutineTableView(frame: .zero, style: .plain, caller: caller)
    private let editRoutineBottomSheetViewController = EditRoutineBottomSheetViewController()
    
    private var caller: ViewCaller
        
    /// 운동 시작 버튼 - 클릭 시 바로 홈화면에서 운동 시작
    private lazy var startButton = UIButton().then {
        $0.setTitle(startText, for: .normal)
        $0.setTitleColor(.background, for: .normal)
        $0.backgroundColor = .brand
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.layer.cornerRadius = 12
    }

    /// 초기화 메서드 - reactor 주입
    /// - Parameter reactor: EditRoutine 화면의 상태 및 액션을 관리하는 리액터 객체
    init(reactor: EditRoutineViewReactor, coordinator: EditRoutineCoordinatorProtocol, caller: ViewCaller) {
        self.coordinator = coordinator
        self.caller = caller
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    /// 스토리보드나 XIB 사용 시 호출되나, 본 프로젝트에서는 사용하지 않음
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 뷰 컨트롤러 뷰가 메모리에 로드된 후 호출
    /// UI 구성 및 초기 데이터 적용 수행
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reactor?.action.onNext(.viewDidLoad)
    }
    
    func bind(reactor: EditRoutineViewReactor) {
        tableView.cellMoreButtonTapped
            .do(onNext: { [weak self] indexPath in
                self?.presentBottomSheetVC()})
            .map{ Reactor.Action.cellButtonTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.footerViewTapped
            .do(onNext: { [weak self] in
                self?.presentEditExerciseVC()
            }).map { Reactor.Action.plusExcerciseButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.dragDropRelay
            .distinctUntilChanged { $0.source == $1.source && $0.destination == $1.destination }
            .map{ Reactor.Action.reorderWorkout(source: $0, destination: $1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editRoutineBottomSheetViewController.excerciseChangeButtonSubject
            .map{ Reactor.Action.changeWorkoutInfo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editRoutineBottomSheetViewController.removeExcerciseButtonSubject
            .map{ Reactor.Action.removeSelectedWorkout }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editRoutineBottomSheetViewController.changeExcerciseListButtonSubject
            .map{ Reactor.Action.changeListOrder }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let self else { return }
                UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                    self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                        self.startButton.transform = .identity
                    }, completion: { _ in
                        self.coordinator.navigateToHomeViewWithWorkoutStarted()
                        self.dismiss(animated: true)
                    })
                })
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.routine }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, item in
                owner.tableView.apply(routine: item)
            }.disposed(by: disposeBag)
    }
    
    func presentBottomSheetVC() {
        if let sheet = editRoutineBottomSheetViewController.sheetPresentationController {
            let fixedHeight: CGFloat = 200

            sheet.detents = [.custom(resolver: { _ in
                fixedHeight
            })]
            sheet.prefersGrabberVisible = true

            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true // iPhone에서 전체화면 방지
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }

        navigationController?.present(editRoutineBottomSheetViewController, animated: true)
    }
    
    func presentEditExerciseVC() {
        let vc = AddExcerciseViewController(
            reactor: AddExcerciseViewReactor(
                routineName: reactor?.currentState.routine.name ?? "알수없음",
                saveRoutineUseCase: SaveRoutineUseCase(repository: RoutineRepositoryImpl()),
                workoutStateForEdit: nil,
                caller: .fromHome)
        )
        self.present(vc, animated: true)
    }
}

// MARK: - UI 구성 관련 private 메서드
private extension EditRoutineViewController {
    
    /// UI 초기 설정 호출 메서드
    func setupUI() {
        setAppearance()
        setDelegates()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 배경색 및 뷰 기본 외관 설정
    func setAppearance() {
        view.backgroundColor = .background
    }
    
    /// 델리게이트 및 데이터소스 할당 (필요 시 구현)
    func setDelegates() {
        // 예: tableView.delegate = self
    }
    
    /// 서브뷰를 뷰 계층에 추가
    func setViewHierarchy() {
        view.addSubviews(tableView, startButton)
    }
    
    /// SnapKit을 이용한 레이아웃 제약 설정
    func setConstraints() {
        
        tableView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(startButton.snp.top)
        }
        
        startButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        }
    }
}
