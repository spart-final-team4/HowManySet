//
//  EditExcerciseContentView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/15/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 운동 정보(세트 단위)를 입력할 수 있는 콘텐츠 뷰입니다.
///
/// 구성 요소:
/// - 상단 헤더 뷰 (`EditExcerciseContentHeaderView`)
/// - "세트 / 무게 / 개수" 타이틀 스택뷰
/// - 동적으로 추가되는 세트 입력 행들 (`EditExcerciseHorizontalContentStackView`)
/// - "+ 세트 추가하기" 버튼
///
/// 기능:
/// - 초기 3개의 세트를 자동으로 생성합니다.
/// - 버튼을 눌러 세트를 추가할 수 있습니다.
/// - 각 세트는 삭제 버튼을 포함하며 삭제 시 순서가 재정렬됩니다.
final class EditExerciseContentView: UIView {
    
    /// Rx 자원 해제를 위한 DisposeBag입니다.
    private let disposeBag = DisposeBag()
    
    /// 상단 단위 선택 헤더 뷰입니다.
    private let headerView = EditExerciseContentHeaderView()
    private(set) var unitSelectionRelay = BehaviorRelay<String>(value: "kg")
    private(set) var exerciseInfoRelay = BehaviorRelay<[[String]]>(value: [[]])
    
    /// 세트 정보와 추가 버튼을 포함하는 수직 스택뷰입니다.
    private let verticalContentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .center
        $0.distribution = .fill
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    /// "세트 / 무게 / 개수" 항목명을 나타내는 수평 스택뷰입니다.
    private let horizontalContentTitleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 28
        
        let setLabel = UILabel(text: String(localized: "세트"),
                               textColor: .white,
                               font: .pretendard(size: 14, weight: .regular),
                               alignment: .center)
        let unitLabel = UILabel(text: String(localized: "무게"),
                                textColor: .white,
                                font: .pretendard(size: 14, weight: .regular),
                                alignment: .center)
        let countLabel = UILabel(text: String(localized: "개수"),
                                 textColor: .white,
                                 font: .pretendard(size: 14, weight: .regular),
                                 alignment: .center)
        let emptyLabel = UILabel(text: " ",
                                 textColor: .white,
                                 font: .pretendard(size: 14, weight: .regular),
                                 alignment: .center)
        
        $0.addArrangedSubviews(setLabel, unitLabel, countLabel, emptyLabel)
        $0.configureContentLayoutArrangeSubViews() // 커스텀 정렬 설정
    }
    
    /// 세트를 추가하는 버튼입니다.
    private let addContentButton = UIButton().then {
        $0.setTitle(String(localized: "+ 세트 추가하기"), for: .normal)
        $0.titleLabel?.font = .pretendard(size: 18, weight: .medium)
        $0.setTitleColor(.textTertiary, for: .normal)
        $0.titleLabel?.textAlignment = .left
    }
    
    /// 초기화 메서드 - 기본 UI 구성과 버튼 이벤트 바인딩을 수행합니다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// XIB/Storyboard 초기화는 지원하지 않습니다.
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 새로운 세트 입력 행을 추가합니다.
    private func addContentView() {
        // 세트 순서를 결정
        let order = verticalContentStackView.subviews.count - 1
        let contentView = EditExerciseHorizontalContentStackView(order: order)
        
        // 기존 추가 버튼 제거 후, 새로운 세트와 함께 다시 추가
        verticalContentStackView.removeArrangedSubview(addContentButton)
        addContentButton.removeFromSuperview()
        verticalContentStackView.addArrangedSubviews(contentView, addContentButton)
        
        // 삭제 버튼 이벤트 처리
        contentView.removeButtonTap
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, _ in
                owner.verticalContentStackView.removeArrangedSubview(contentView)
                contentView.removeFromSuperview()
                owner.reorder()
                var newValue = owner.exerciseInfoRelay.value
                newValue.remove(at: contentView.order)
                owner.exerciseInfoRelay.accept(newValue)
            }.disposed(by: disposeBag)
        
        exerciseInfoRelay.accept(exerciseInfoRelay.value + [["", ""]])
        
        contentView.weightRepsRelay
            .subscribe(with: self) { owner, element in
                if owner.exerciseInfoRelay.value.count > contentView.order {
                    var newValue = owner.exerciseInfoRelay.value
                    newValue[contentView.order] = element
                    owner.exerciseInfoRelay.accept(newValue)
                    // 해당 셀 아래 모든 셀 값 변경
                    let belowStart = contentView.order + 1
                    let numSubviews = owner.verticalContentStackView.arrangedSubviews.count
                    for idx in belowStart..<(numSubviews - 1) {
                        if let belowCell = owner.verticalContentStackView.arrangedSubviews[idx] as? EditExerciseHorizontalContentStackView {
                            belowCell.configure(weight: Double(element[0]) ?? 0.0, reps: Int(element[1]) ?? 0)
                        }
                        if newValue.count > idx {
                            newValue[idx] = element
                        }
                    }
                    owner.exerciseInfoRelay.accept(newValue)
                }
            }.disposed(by: disposeBag)
    }
    
    /// 현재 세트 목록을 기준으로 순서를 재설정합니다.
    private func reorder() {
        for i in 0..<verticalContentStackView.subviews.count {
            guard let view = verticalContentStackView.subviews[i] as? EditExerciseHorizontalContentStackView else { continue }
            view.reOrderLabel(order: i)
        }
    }
    
    /// 초기 상태에서 5개의 세트를 자동 추가합니다.
    func setInitialState() {
        for _ in 1...5 {
            addContentView()
        }
    }
    
    func returnInitialState() {
        verticalContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        verticalContentStackView.addArrangedSubviews(
            horizontalContentTitleStackView,
            addContentButton
        )
        exerciseInfoRelay.accept([[]])
        setInitialState()
    }
}

// MARK: - UI 구성 메서드

private extension EditExerciseContentView {
    
    /// 전체 UI 구성 흐름을 정의합니다.
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
        bind()
    }
    func bind() {
        // "+ 세트 추가하기" 버튼 탭 시 새 세트 추가
        addContentButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, _ in
                owner.addContentButton.animateTap {
                    owner.addContentView()
                }
            }
            .disposed(by: disposeBag)

        headerView.unitSelectionRelay
            .bind(to: unitSelectionRelay)
            .disposed(by: disposeBag)
    }
    
    /// 배경색 등 외형을 설정합니다.
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 뷰 계층을 구성합니다.
    func setViewHierarchy() {
        verticalContentStackView.addArrangedSubviews(
            horizontalContentTitleStackView,
            addContentButton
        )
        self.addSubviews(headerView, verticalContentStackView)
    }
    
    /// SnapKit을 활용하여 오토레이아웃을 설정합니다.
    func setConstraints() {
        headerView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
            $0.top.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        verticalContentStackView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Internal Methods
extension EditExerciseContentView {
    
    func configureSets(with sets: [[String]]) {
        
        verticalContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        verticalContentStackView.addArrangedSubview(horizontalContentTitleStackView)
        
        // 세트 개수만큼 세트 행 추가
        for (index, set) in sets.enumerated() {
            let hContentStackView = EditExerciseHorizontalContentStackView(order: index)
            
            // (무게, 개수)
            if set.count == 2 {
                hContentStackView.configure(weight: Double(set[0]) ?? 0.0, reps: Int(set[1]) ?? 0)
            }
            verticalContentStackView.addArrangedSubview(hContentStackView)
        }
        
        verticalContentStackView.addArrangedSubview(addContentButton)
        
        exerciseInfoRelay.accept(sets)
    }
}

extension EditExerciseContentView {
    
    func configureEditSets(with sets: [WorkoutSet]) {
        
        verticalContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        verticalContentStackView.addArrangedSubview(horizontalContentTitleStackView)
        
        configureUnitSegment(unit: sets[0].unit)
        
        for i in 0..<sets.count {
            // 세트 순서를 결정
            let order = i + 1
            let contentView = EditExerciseHorizontalContentStackView(order: order)
            let weight = sets[i].weight
            let reps = sets[i].reps
            
            // 기존 추가 버튼 제거 후, 새로운 세트와 함께 다시 추가
            verticalContentStackView.removeArrangedSubview(addContentButton)
            addContentButton.removeFromSuperview()
            verticalContentStackView.addArrangedSubviews(contentView, addContentButton)
            
            contentView.removeButtonTap
                .observe(on: MainScheduler.instance)
                .subscribe(with: self) { owner, _ in
                    owner.verticalContentStackView.removeArrangedSubview(contentView)
                    contentView.removeFromSuperview()
                    owner.reorder()
                    var newValue = owner.exerciseInfoRelay.value
                    newValue.remove(at: contentView.order)
                    owner.exerciseInfoRelay.accept(newValue)
                }.disposed(by: disposeBag)
            
            contentView.weightRepsRelay
                .skip(1)
                .subscribe(with: self) { owner, element in
                    if owner.exerciseInfoRelay.value.count > contentView.order {
                        var newValue = owner.exerciseInfoRelay.value
                        newValue[contentView.order] = element
                        owner.exerciseInfoRelay.accept(newValue)
                        // 해당 셀 아래 모든 셀 값 변경
                        let belowStart = contentView.order + 1
                        let numSubviews = owner.verticalContentStackView.arrangedSubviews.count
                        for idx in belowStart..<(numSubviews - 1) {
                            if let belowCell = owner.verticalContentStackView.arrangedSubviews[idx] as? EditExerciseHorizontalContentStackView {
                                belowCell.configure(weight: Double(element[0]) ?? 0.0, reps: Int(element[1]) ?? 0)
                            }
                            if newValue.count > idx {
                                newValue[idx] = element
                            }
                        }
                        owner.exerciseInfoRelay.accept(newValue)
                    }
                }.disposed(by: disposeBag)
            contentView.configure(weight: weight, reps: reps)
            exerciseInfoRelay.accept(exerciseInfoRelay.value + [[String(weight), String(reps)]])
        }
    }
    
    func configureUnitSegment(unit: String) {
        headerView.configureUnitSegment(unit: unit)
    }
}
