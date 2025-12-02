//
//  MyPageHeaderView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift

/// 마이페이지 상단에 사용자 이름(또는 비회원)을 표시하는 헤더 뷰
/// - 사용자 식별 또는 상태 표시 용도로 사용됩니다.
final class MyPageHeaderView: UIView {
    
    private(set) var membershipButtonTapped = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    /// 사용자 이름 또는 상태(예: 비회원)를 표시하는 레이블
    let usernameLabel = UILabel().then {
        $0.font = .pretendard(size: 36, weight: .regular)
        $0.numberOfLines = 0
        $0.text = String(localized: "비회원") // 기본값
        $0.textColor = .white
    }
    
    private let membershipButton = UIButton().then {
        $0.setTitle("회원전환", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.backgroundColor = .brand
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    /// 코드 기반 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 스토리보드 사용 불가 (명시적 제한)
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MyPageHeaderView {
    
    /// UI 설정을 위한 메서드 모음 호출
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
        bind()
    }
    
    func bind() {
        membershipButton.rx.tap
            .bind(to: membershipButtonTapped)
            .disposed(by: disposeBag)
    }
    
    /// 배경색 등 뷰의 외형 설정
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 서브뷰(요소) 계층 구성
    func setViewHierarchy() {
        self.addSubviews(usernameLabel, membershipButton)
    }
    
    /// 오토레이아웃 제약 설정
    func setConstraints() {
        usernameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        membershipButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(15)
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
    }
}
