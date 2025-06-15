//
//  EditExcerciseCurrentStackView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit
import SnapKit
import Then

/// 현재 저장된 운동 목록을 보여주는 수직 스택뷰입니다.
///
/// 구성 요소:
/// - 타이틀 라벨 (예: "현재 운동 목록")
/// - 운동 개수 라벨 (예: "2개의 운동")
/// - 운동이 없을 때 표시되는 빈 텍스트 라벨
/// - 운동이 추가되면 나타나는 `SavedExcerciseView` 목록
///
/// 기능:
/// - `addExcercise(name:setCount:)`를 통해 운동 항목을 동적으로 추가할 수 있으며,
///   첫 추가 시 `emptyTextLabel`은 제거됩니다.
final class EditExcerciseCurrentStackView: UIStackView {
    
    /// 상단에 위치한 섹션 타이틀 라벨입니다.
    private let titleLabel = UILabel().then {
        $0.text = "현재 운동 목록"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 20, weight: .regular)
    }
    
    /// 현재 추가된 운동 수를 나타내는 라벨입니다.
    private let excerciseCountLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    
    /// 운동이 추가되지 않았을 때 표시되는 안내 라벨입니다.
    private let emptyTextLabel = UILabel().then {
        $0.text = "아직 추가된 운동이 없습니다."
        $0.textColor = .dbTypo
        $0.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    /// 초기화 메서드 - 스택뷰 설정 및 UI 구성 호출
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        axis = .vertical
        spacing = 20
        distribution = .equalSpacing
    }
    
    /// 스토리보드 사용 불가
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 운동 항목을 추가합니다.
    /// - Parameters:
    ///   - name: 운동 이름
    ///   - setCount: 해당 운동의 세트 수
    func addExcercise(name: String, setCount: Int) {
        let view = SavedExcerciseView(name: name, setCount: setCount)
        
        // 빈 안내 라벨 제거 (최초 추가 시)
        self.removeArrangedSubview(emptyTextLabel)
        emptyTextLabel.removeFromSuperview()
        
        // 운동 뷰 추가
        self.addArrangedSubviews(view)
        
        // 개수 라벨 갱신
        self.excerciseCountLabel.text = "\(self.arrangedSubviews.count - 1)개의 운동"
    }
}

// MARK: - UI 구성 관련 메서드
private extension EditExcerciseCurrentStackView {
    
    /// 전체 UI 구성 흐름을 정의합니다.
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
    }
    
    /// 외형 스타일을 설정합니다.
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 서브뷰 및 스택뷰 구성 요소를 추가합니다.
    func setViewHierarchy() {
        self.addSubview(excerciseCountLabel)
        self.addArrangedSubviews(titleLabel, emptyTextLabel)
    }
    
    /// SnapKit을 사용하여 오토레이아웃 제약을 설정합니다.
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
        emptyTextLabel.snp.makeConstraints {
            $0.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
        excerciseCountLabel.snp.makeConstraints {
            $0.trailing.equalTo(titleLabel.snp.trailing).inset(40)
            $0.top.equalToSuperview().offset(4)
        }
    }
}

