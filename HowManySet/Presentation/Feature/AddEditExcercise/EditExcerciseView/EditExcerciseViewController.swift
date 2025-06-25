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

final class EditExcerciseViewController: UIViewController, View {
    
    typealias Reactor = EditExcerciseViewReactor
    
    var disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let headerView = EditExcerciseHeaderView()
    private let headerBorderLineView = UIView().then {
        $0.backgroundColor = .systemGray3
    }
    private let contentView = EditExcerciseContentView()
    private let footerView = EditExcerciseFooterView()
    
    init(reactor: EditExcerciseViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        setupUI()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: EditExcerciseViewReactor) {
        
    }
    
}

// MARK: - UI Layout Methods

private extension EditExcerciseViewController {
    
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
