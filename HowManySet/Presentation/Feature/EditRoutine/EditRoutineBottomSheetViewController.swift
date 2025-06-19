//
//  EditRoutineBottomSheetViewController.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 운동 루틴 편집 화면에서 나타나는 바텀시트 뷰 컨트롤러입니다.
/// 사용자는 이 뷰에서 다음 작업을 수행할 수 있습니다:
/// - 운동 정보 변경
/// - 선택된 운동 삭제
/// - 운동 목록 순서 변경
///
/// 버튼은 좌측 정렬된 텍스트와 패딩을 포함한 스타일로 구성됩니다.
/// iOS 15 이상에서 deprecated된 `contentEdgeInsets`는 추후 `UIButton.Configuration` 기반으로 전환 권장됩니다.
final class EditRoutineBottomSheetViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private(set) var excerciseChangeButtonSubject = PublishRelay<Void>()
    private(set) var removeExcerciseButtonSubject = PublishRelay<Void>()
    private(set) var changeExcerciseListButtonSubject = PublishRelay<Void>()
    
    /// 운동 정보 변경 버튼
    private lazy var excerciseChangeButton = UIButton().then {
        $0.setTitle("운동 정보 변경", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.titleLabel?.textColor = .textTertiary
        $0.contentHorizontalAlignment = .leading
        $0.contentEdgeInsets = .init(top: 13, left: 12, bottom: 13, right: 12)
        $0.backgroundColor = .disabledButton
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    /// 선택된 운동 삭제 버튼
    private lazy var removeExcerciseButton = UIButton().then {
        $0.setTitle("선택 운동 삭제", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.titleLabel?.textColor = .textTertiary
        $0.contentHorizontalAlignment = .leading
        $0.contentEdgeInsets = .init(top: 13, left: 12, bottom: 13, right: 12)
        $0.backgroundColor = .disabledButton
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    /// 운동 목록 순서 변경 버튼
    private lazy var changeExcerciseListButton = UIButton().then {
        $0.setTitle("목록 순서 변경", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.titleLabel?.textColor = .textTertiary
        $0.contentHorizontalAlignment = .leading
        $0.contentEdgeInsets = .init(top: 13, left: 12, bottom: 13, right: 12)
        $0.backgroundColor = .disabledButton
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    /// 버튼들을 수직으로 배치하는 스택 뷰
    private lazy var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 12
        $0.addArrangedSubviews(excerciseChangeButton, removeExcerciseButton, changeExcerciseListButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - UI 설정
private extension EditRoutineBottomSheetViewController {
    
    /// 전체 UI 설정을 수행합니다.
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
        bind()
    }
    
    func bind() {
        excerciseChangeButton.rx.tap
            .bind(to: excerciseChangeButtonSubject)
            .disposed(by: disposeBag)
        removeExcerciseButton.rx.tap
            .bind(to: removeExcerciseButtonSubject)
            .disposed(by: disposeBag)
        changeExcerciseListButton.rx.tap
            .bind(to: changeExcerciseListButtonSubject)
            .disposed(by: disposeBag)
        
        Observable
            .merge(excerciseChangeButton.rx.tap.asObservable(),
                   removeExcerciseButton.rx.tap.asObservable(),
                   changeExcerciseListButton.rx.tap.asObservable())
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
    
    /// 뷰의 기본 배경 색상 설정
    func setAppearance() {
        view.backgroundColor = .background
    }
    
    /// 서브뷰 계층 설정
    func setViewHierarchy() {
        view.addSubviews(stackView)
    }
    
    /// 오토레이아웃 제약 설정
    func setConstraints() {
        stackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.height.equalTo(150)
        }
    }
}
