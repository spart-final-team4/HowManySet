//
//  EditExcerciseViewController.swift
//  HowManySet
//
//  Created by MJ Dev on 6/26/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class EditExerciseViewController: UIViewController, View {
    
    typealias Reactor = EditExerciseViewReactor
    
    var disposeBag = DisposeBag()
    
    var onDismiss: (() -> Void)?
    
    private let scrollView = UIScrollView()
    private let headerView = EditExerciseHeaderView()
    private let headerBorderLineView = UIView().then {
        $0.backgroundColor = .systemGray3
    }
    private let contentView = EditExerciseContentView()
    private let footerView = EditExerciseFooterView()
    
    private(set) var saveResultRelay = PublishRelay<Bool>()
    
    init(reactor: EditExerciseViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        setupUI()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bind(reactor: EditExerciseViewReactor) {
        
        contentView.unitSelectionRelay
            .map { Reactor.Action.changeUnit($0) }
            .skip(1)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        footerView.saveExcerciseButtonRelay
            .map { [unowned self] in
                LoadingIndicator.showBottomSheetLoadingIndicator(on: self)
                return Reactor.Action.saveExcerciseButtonTapped((self.getCurrentName(), self.getCurrentWorkoutSets()))
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // textField 밖에 누르면 키보드 내려가도록 구현
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .bind { [weak self] _ in
                guard let self else { return }
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.workout }
            .distinctUntilChanged()
            .subscribe(with: self) { owner, workout in
                if case .forEdit = reactor.currentState.mode {
                    owner.contentView.configureEditSets(with: workout.sets)
                    owner.headerView.editConfigure(with: workout.name)
                }
            }.disposed(by: disposeBag)
        
        // Alert 표시 (저장 성공/실패, 유효성 실패 등)
        reactor.alertRelay
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { (owner: EditExerciseViewController, alert) in
                LoadingIndicator.hideBottomSheetLoadingIndicator(on: owner)
                switch alert {
                case .success:
                    owner.saveResultRelay.accept(true)
                    owner.dismiss(animated: true)
                case .workoutNameEmpty:
                    owner.present(owner.defaultAlert(
                        title: String(localized: "오류"),
                        message: String(localized: "운동 이름을 입력해주세요.")
                    ), animated: true)
                case .workoutEmpty:
                    owner.present(owner.defaultAlert(
                        title: String(localized: "오류"),
                        message: String(localized: "현재 저장된 운동 항목이 없어요.")
                    ), animated: true)
                case .workoutInvalidCharacters:
                    owner.present(owner.defaultAlert(
                        title: String(localized: "오류"),
                        message: String(localized: "운동 세트와 개수를 입력해주세요.")
                    ), animated: true)
                case .workoutNameTooLong:
                    owner.present(owner.defaultAlert(
                        title: String(localized: "오류"),
                        message: String(localized: "운동 이름이 너무 길어요.")
                    ), animated: true)
                case .workoutNameTooShort:
                    owner.present(owner.defaultAlert(
                        title: String(localized: "오류"),
                        message: String(localized: "운동 이름이 너무 짧아요.")
                    ), animated: true)
                case .workoutContainsZero:
                    owner.present(owner.defaultAlert(
                        title: String(localized: "오류"),
                        message: String(localized: "0은 입력할 수 없어요.")
                    ), animated: true)
                case .workoutSetsEmpty:
                    owner.present(owner.defaultAlert(
                        title: String(localized: "오류"),
                        message: String(localized: "빈 항목은 저장할 수 없어요.")
                    ), animated: true)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}

// MARK: - UI Layout Methods

private extension EditExerciseViewController {
    
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
            contentView
        )
        view.addSubviews(scrollView, footerView)
    }
    
    /// SnapKit을 활용한 오토레이아웃 제약 조건 설정입니다.
    func setConstraints() {
        headerView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.horizontalEdges.top.equalToSuperview()
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
            $0.bottom.equalToSuperview().inset(30)
        }
        
        scrollView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(footerView.snp.top)
        }
        
        footerView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(52)
        }
    }
}

private extension EditExerciseViewController {
    func getCurrentWorkoutSets() -> [[String]] {
        return contentView.excerciseInfoRelay.value
    }
    
    func getCurrentName() -> String {
        return headerView.exerciseNameRelay.value
    }
}
