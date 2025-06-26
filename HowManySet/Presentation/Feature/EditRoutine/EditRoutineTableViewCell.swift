//
//  EditRoutineTableViewCell.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift

/// 운동 루틴 편집 화면에서 각 운동 항목을 표시하는 테이블 뷰 셀
/// - 기능: 운동 이름, 세트 수, 무게, 반복 횟수를 보여주며, 우측에 더보기 버튼을 배치
final class EditRoutineTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    var moreButtonTapped = PublishRelay<Void>()
    
    /// 셀 재사용을 위한 식별자
    static var identifier: String {
        return String(describing: self)
    }
    
    /// 운동 이름을 표시하는 라벨
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .regular)
        $0.textColor = .white
    }
    
    /// 세트 수 텍스트 라벨
    private let setTextLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .systemGray2
    }
    
    /// 무게 텍스트 라벨
    private let weightTextLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .systemGray2
    }
    
    /// 반복 횟수 텍스트 라벨
    private let repsTextLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .systemGray2
    }
    
    /// 더보기 버튼 (ellipsis 아이콘)
    private let moreButton = UIButton().then {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .systemGray3
    }
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    /// 셀을 모델 데이터로 구성하는 메서드
    /// - Parameter model: 운동 정보를 담고 있는 `EditRoutioneCellModel` 객체
    func configure(model: EditRoutioneCellModel, caller: ViewCaller) {
        self.titleLabel.text = model.name
        self.setTextLabel.text = model.setText
        self.weightTextLabel.text = model.weightText
        self.repsTextLabel.text = model.repsText
        
        self.moreButton.isHidden = caller == .fromHome ? true : false
    }
}

// MARK: - Private UI Setup
private extension EditRoutineTableViewCell {
    
    /// UI 초기 설정 호출 메서드
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
        bind()
    }
    
    func bind() {
        moreButton.rx.tap
            .bind(to: moreButtonTapped)
            .disposed(by: disposeBag)
    }
    
    /// 셀 배경색 및 기본 속성 설정
    func setAppearance() {
        contentView.backgroundColor = .background
    }
    
    /// 서브뷰 계층에 추가
    func setViewHierarchy() {
        contentView.addSubviews(titleLabel, setTextLabel, weightTextLabel, repsTextLabel, moreButton)
    }
    
    /// SnapKit을 이용한 오토레이아웃 제약 설정
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
        }
        setTextLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }
        weightTextLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(setTextLabel.snp.trailing).offset(16)
        }
        repsTextLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(weightTextLabel.snp.trailing).offset(16)
        }
        moreButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
