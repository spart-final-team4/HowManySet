//
//  SavedExerciseView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//
import UIKit
import SnapKit
import Then

/// 저장된 운동 정보를 나타내는 단일 행 뷰입니다.
///
/// `EditExcerciseCurrentStackView`에 사용되며, 운동 이름과 세트 수 정보를 표시합니다.
///
/// 구성 요소:
/// - 운동 이름 (`excerciseNameLabel`)
/// - 세트 수 (`setCountLabel`)
final class SavedExerciseView: UIView {
    
    /// 운동 이름을 표시하는 라벨입니다.
    private let excerciseNameLabel = UILabel().then {
        $0.font = .pretendard(size: 16, weight: .regular)
        $0.textColor = .white
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }
    
    /// 세트 수를 표시하는 라벨입니다. (예: "3세트")
    private let setCountLabel = UILabel().then {
        $0.font = .pretendard(size: 12, weight: .regular)
        $0.textColor = .dbTypo
        $0.textAlignment = .right
        $0.numberOfLines = 1
    }
    
    /// 기본 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 운동 이름과 세트 수를 지정하여 초기화할 수 있는 편의 생성자
    /// - Parameters:
    ///   - name: 운동 이름 (예: "벤치프레스")
    ///   - setCount: 세트 수 (예: 3)
    convenience init(name: String, setCount: Int) {
        self.init(frame: .zero)
        self.excerciseNameLabel.text = name
        self.setCountLabel.text = String(format: String(localized: "%d세트"), setCount)
    }
    
    convenience init(workout: Workout) {
        self.init(frame: .zero)
        self.excerciseNameLabel.text = workout.name
        self.setCountLabel.text = String(
            format: String(localized: "%d세트 * %@%@ * 총 %d회"),
            workout.sets.count,
            "\(workout.sets.map{ $0.weight }.max()!)",
            workout.sets[0].unit,
            workout.sets.map{ $0.reps }.reduce(0, +)
        )
    }
    
    /// 스토리보드 사용 불가
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI 관련 메서드 정의
private extension SavedExerciseView {
    
    /// UI 전체 구성을 담당하는 메서드입니다.
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
    }
    
    /// 외형 설정 - 배경색 지정
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 뷰 계층 구성 - 하위 뷰 추가
    func setViewHierarchy() {
        self.addSubviews(excerciseNameLabel, setCountLabel)
    }
    
    /// SnapKit을 이용한 오토레이아웃 설정
    func setConstraints() {
        excerciseNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(4)
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        setCountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(excerciseNameLabel.snp.trailing).offset(15)
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(4)
        }
    }
}
