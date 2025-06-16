//
//  EditExcerciseContentHeaderView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/15/25.
//

import UIKit
import SnapKit
import Then

/// 운동 정보 입력 화면 상단에 사용되는 헤더 뷰입니다.
///
/// 좌측에는 "운동정보 입력"이라는 제목이 표시되며,
/// 우측에는 단위 선택을 위한 커스텀 세그먼트 컨트롤(`kg`, `lbs`)이 배치됩니다.
final class EditExcerciseContentHeaderView: UIView {
    
    /// 운동 정보 입력 안내 문구를 표시하는 라벨입니다.
    private let titleLabel = UILabel().then {
        $0.text = "운동정보 입력"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 20)
    }
    
    /// 무게 단위를 선택할 수 있는 커스텀 세그먼트 컨트롤입니다.
    ///
    /// "kg" 또는 "lbs" 중 하나를 선택할 수 있습니다.
    private let unitSegmentControl = CustomSegmentControl(titles: ["kg", "lbs"])
    
    /// 코드 기반 초기화 시 호출되는 이니셜라이저입니다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        unitSegmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    /// 스토리보드 또는 XIB 초기화는 지원하지 않습니다.
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 세그먼트 컨트롤의 값이 변경될 때 호출되는 액션입니다.
    @objc func segmentChanged() {
        // 단위 변경 시 필요한 동작을 이곳에 구현합니다.
    }
}

// MARK: - UI 구성 관련 메서드

private extension EditExcerciseContentHeaderView {
    
    /// 전체 UI 구성 흐름을 정의합니다.
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
    }
    
    /// 배경색 등 외형 스타일을 설정합니다.
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 라벨 및 세그먼트 컨트롤을 서브뷰로 추가합니다.
    func setViewHierarchy() {
        self.addSubviews(titleLabel, unitSegmentControl)
    }
    
    /// SnapKit을 사용하여 오토레이아웃을 설정합니다.
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
        }
        unitSegmentControl.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(32)
        }
    }
}

