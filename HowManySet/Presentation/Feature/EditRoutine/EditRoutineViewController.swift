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
    
    private let startText = String(localized: "시작")
    
    private let coordinator: EditRoutineCoordinatorProtocol
    
    /// 운동 루틴 리스트를 보여주는 테이블 뷰
    private lazy var tableView = EditRoutineTableView(frame: .zero, style: .plain, caller: self.caller)
    private let changeExcerciseTapped = PublishRelay<Void>()
    private var caller: ViewCaller
    /// 운동 시작 버튼 - 클릭 시 바로 홈화면에서 운동 시작
    private lazy var startButton = UIButton().then {
        $0.setTitle(startText, for: .normal)
        $0.setTitleColor(.background, for: .normal)
        $0.backgroundColor = .brand
        $0.titleLabel?.font = .pretendard(size: 18, weight: .medium)
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
                self?.presentBottomSheetVC()
                print("cellMoreButtonTapped")
            })
            .map{ Reactor.Action.cellButtonTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.footerViewTapped
            .observe(on: MainScheduler.instance)
            .subscribe(with: self,
                       onNext: { owner, _ in
                owner.presentAddExerciseVC(routine: reactor.currentState.routine)
            })
            .disposed(by: disposeBag)
        
        tableView.dragDropRelay
            .distinctUntilChanged { $0.source == $1.source && $0.destination == $1.destination }
            .map{ Reactor.Action.reorderWorkout(source: $0, destination: $1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(with: self) { owner, _ in
                owner.startButton.animateTap {
                    if let updatedRoutine = owner.reactor?.currentState.routine {
                        owner.coordinator.navigateToHomeViewWithWorkoutStarted(updateRoutine: updatedRoutine)
                    }
                    owner.dismiss(animated: true)
                }
            }
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
        
        let editRoutineBottomSheetViewController = EditRoutineBottomSheetViewController()
        
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
        
        editRoutineBottomSheetViewController.excerciseChangeButtonSubject
            .bind(to: changeExcerciseTapped)
            .disposed(by: editRoutineBottomSheetViewController.disposeBag)
        
        changeExcerciseTapped
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
                owner.presentEditExcerciseVC()
            }.disposed(by: editRoutineBottomSheetViewController.disposeBag)
        
        editRoutineBottomSheetViewController.removeExcerciseButtonSubject
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true) { // 바텀시트 닫기
                    self.showToast(x: 0, y: 0, message: String(localized: "선택한 운동이 삭제되었어요!"))
                }
                owner.reactor?.action.onNext(.removeSelectedWorkout) // 삭제 액션 전달
            }
            .disposed(by: editRoutineBottomSheetViewController.disposeBag)
        
        // TODO: 순서변경 마이너패치때
//        editRoutineBottomSheetViewController.changeExcerciseListButtonSubject
//            .map{ Reactor.Action.changeListOrder }
//            .bind(to: reactor!.action)
//            .disposed(by: editRoutineBottomSheetViewController.disposeBag)

        navigationController?.present(editRoutineBottomSheetViewController, animated: true)
    }
    
    func presentAddExerciseVC(routine: WorkoutRoutine) {
        coordinator.presentAddExerciseView(routine: routine) { [weak self] result in
            guard let self else { return }
            if result {
                self.showToast(x: 0, y: 0, message: "저장되었어요!")
                self.reactor?.action.onNext(.viewDidLoad)
            }
        }
    }

    func presentEditExcerciseVC() {
        guard let workout = reactor?.currentState.currentSeclectedWorkout else { return }

        // VC는 사용자의 Action에 따라 상태를 업데이트하는 데에 집중
        coordinator.presentEditExerciseView(workout: workout) { [weak self] result in
            guard let self else { return }
            if result {
                self.showToast(x: 0, y: 0, message: String(localized: "저장되었어요!"))
                self.reactor?.action.onNext(.viewDidLoad)
            }
        }
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
