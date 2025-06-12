//
//  MyPageView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit
import SnapKit
import Then

/// 마이페이지 화면의 전체 뷰를 구성하는 뷰 클래스
/// - 헤더 영역과 컬렉션 뷰로 구성되며, MVVM 또는 ReactorKit에서 View 역할을 수행
final class MyPageView: UIView {
    
    /// 사용자 이름 또는 상태를 표시하는 헤더 뷰
    private let headerView = MyPageHeaderView()
    
    /// 마이페이지 목록을 표시하는 컬렉션 뷰
    let collectionView = MyPageCollectionView()
    
    /// 코드로 뷰를 초기화할 때 사용되는 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 스토리보드 사용을 명시적으로 제한
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MyPageView {
    
    /// UI 구성 흐름을 제어하는 메서드
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 배경색 등 외형 속성 설정
    func setAppearance() {
        self.backgroundColor = .bsInputFieldBG
    }
    
    /// 서브뷰를 계층 구조에 추가
    func setViewHierarchy() {
        self.addSubviews(headerView, collectionView)
    }
    
    /// 오토레이아웃 제약을 설정
    func setConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(80) // 헤더 높이 고정
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
