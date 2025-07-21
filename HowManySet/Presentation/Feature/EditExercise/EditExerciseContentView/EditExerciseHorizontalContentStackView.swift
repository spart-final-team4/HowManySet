//
//  EditExcerciseHorizontalContentStackView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 운동 세트 정보를 가로로 나열하여 보여주는 스택뷰입니다.
///
/// 구성 요소:
/// - 순서 라벨 (`orderLabel`)
/// - 무게 입력 필드 (`weightTextField`)
/// - 횟수 입력 필드 (`repsTextField`)
/// - 삭제 버튼 (`removeButton`)
///
/// Rx로 삭제 버튼의 탭 이벤트를 외부에 전달할 수 있도록 `removeButtonTap`을 제공합니다.
final class EditExerciseHorizontalContentStackView: UIStackView {
    
    /// Rx 자원 해제를 위한 DisposeBag입니다.
    private let disposeBag = DisposeBag()
    
    /// 삭제 버튼이 탭되었을 때 이벤트를 방출하는 PublishRelay입니다.
    private(set) var removeButtonTap = PublishRelay<Void>()
    private(set) var weightRepsRelay = BehaviorRelay<[String]>(value: [])
    private(set) var weightRelay = BehaviorRelay<String>(value: "")
    private(set) var repsRelay = BehaviorRelay<String>(value: "")
    
    var order: Int = 0
    
    /// 현재 세트의 순서를 표시하는 라벨입니다.
    private let orderLabel = UILabel().then {
        $0.textColor = .white
        $0.backgroundColor = .disabledButton
        $0.font = .pretendard(size: 16, weight: .regular)
        $0.textAlignment = .center
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    /// 무게를 입력받는 텍스트 필드입니다.
    private let weightTextField = UITextField().then {
        $0.placeholder = String(localized: "입력")
        $0.backgroundColor = .bottomSheetBG
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.textColor = .white
        $0.font = .pretendard(size: 16, weight: .regular)
        $0.keyboardType = .decimalPad
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: $0.frame.height))
        $0.leftView = paddingView
        $0.leftViewMode = .always
    }
    
    /// 반복 횟수를 입력받는 텍스트 필드입니다.
    private let repsTextField = UITextField().then {
        $0.placeholder = String(localized: "입력")
        $0.backgroundColor = .bottomSheetBG
        $0.clipsToBounds = true
        $0.textColor = .white
        $0.font = .pretendard(size: 16, weight: .regular)
        $0.layer.cornerRadius = 12
        $0.keyboardType = .numberPad
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: $0.frame.height))
        $0.leftView = paddingView
        $0.leftViewMode = .always
    }
    
    /// 해당 세트를 삭제할 수 있는 버튼입니다.
    private let removeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "minus"), for: .normal)
        $0.tintColor = .systemGray
        $0.backgroundColor = .bottomSheetBG
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    /// 기본 생성자입니다. UI 구성 및 Rx 바인딩을 수행합니다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        spacing = 28
        distribution = .equalSpacing
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 8, left: 0, bottom: 8, right: 0)
        setupUI()
    }
    
    /// XIB/Storyboard 초기화는 지원하지 않습니다.
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 세트 순서를 전달받아 라벨을 설정하는 편의 생성자입니다.
    ///
    /// - Parameter order: 세트의 순서 (1부터 시작)
    convenience init(order: Int) {
        self.init(frame: .zero)
        self.orderLabel.text = "\(order)"
        self.order = order
    }
    
    /// 외부에서 순서를 재설정할 때 사용하는 메서드입니다.
    ///
    /// - Parameter order: 변경할 순서 값
    func reOrderLabel(order: Int) {
        self.orderLabel.text = "\(order)"
        self.order = order
    }
}

// MARK: - UI 구성 관련 메서드

private extension EditExerciseHorizontalContentStackView {
    
    /// 전체 UI 구성 흐름을 정의합니다.
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
        bind()
    }
    
    func bind() {
        weightTextField.rx.text.orEmpty
            .map { String($0.prefix(5)) }
            .bind(to: weightRelay)
            .disposed(by: disposeBag)
        
        repsTextField.rx.text.orEmpty
            .map { String($0.prefix(4)) }
            .bind(to: repsRelay)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                weightRelay,
                repsRelay
            )
            .map{ [$0, $1] }
            .distinctUntilChanged()
            .bind(to: weightRepsRelay)
            .disposed(by: disposeBag)

        // 삭제 버튼 탭 이벤트 바인딩
        removeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.removeButton.animateTap {
                    self.removeButtonTap.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 배경색 등 외형 스타일을 설정합니다.
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 스택뷰에 포함될 서브뷰들을 추가합니다.
    func setViewHierarchy() {
        self.addArrangedSubviews(orderLabel, weightTextField, repsTextField, removeButton)
    }
    
    /// 스택뷰 내부 컴포넌트에 대한 오토레이아웃을 설정합니다.
    func setConstraints() {
        self.configureContentLayoutArrangeSubViews()  // 이 함수는 외부에서 정의된 커스텀 메서드로 추정됩니다.
    }
}

// MARK: - Internal Methods
extension EditExerciseHorizontalContentStackView {
    
    func configure(weight: Double, reps: Int) {
        self.weightTextField.text = "\(weight.clean)"
        self.repsTextField.text = "\(reps)"
        weightRelay.accept(weightTextField.text ?? "")
        repsRelay.accept(repsTextField.text ?? "")
    }
}
