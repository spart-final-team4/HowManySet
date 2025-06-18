//
//  EditExcerciseViewController.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 운동 루틴 편집 화면을 담당하는 뷰 컨트롤러입니다.
///
/// 주요 구성 요소:
/// - 상단 헤더 (`EditExcerciseHeaderView`)
/// - 세트 편집 영역 (`EditExcerciseContentView`)
/// - 현재 저장된 운동 목록 (`EditExcerciseCurrentStackView`)
/// - 하단 푸터 버튼 (`EditExcerciseFooterView`)
///
/// 사용자가 세트를 추가하고, 운동을 저장하는 등 편집 기능을 제공합니다.
final class EditExcerciseViewController: UIViewController {
    
    // MARK: - Properties
    
    /// ReactorKit 또는 MVVM 패턴을 위한 리액터 객체입니다.
    private let reactor: EditExcerciseViewReactor
    
    /// 메모리 해제를 위한 DisposeBag (RxSwift)
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    /// 전체 콘텐츠를 스크롤 가능하게 하는 스크롤 뷰입니다.
    private let scrollView = UIScrollView()
    
    /// 상단 타이틀/설명 등을 포함하는 헤더 뷰입니다.
    private let headerView = EditExcerciseHeaderView()
    
    /// 헤더와 콘텐츠 사이 구분선
    private let headerBorderLineView = UIView().then {
        $0.backgroundColor = .systemGray3
    }
    
    /// 세트 편집을 위한 콘텐츠 뷰입니다.
    private let contentView = EditExcerciseContentView()
    
    /// 콘텐츠와 현재 운동 리스트 사이 구분선
    private let contentBorderLineView = UIView().then {
        $0.backgroundColor = .systemGray3
    }
    
    /// 현재 추가된 운동 목록을 보여주는 뷰입니다.
    private let currentView = EditExcerciseCurrentStackView()
    
    /// 하단 고정된 액션 버튼(운동 추가, 저장)을 포함하는 푸터 뷰입니다.
    private let footerView = EditExcerciseFooterView()
    
    // MARK: - Initializer
    
    /// 외부에서 리액터를 주입받아 초기화합니다.
    init(reactor: EditExcerciseViewReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    /// 스토리보드 초기화는 지원하지 않습니다.
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    /// 뷰 로드 후 UI 및 바인딩 설정을 수행합니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    /// 버튼 등의 이벤트 바인딩 처리
    func bind() {
        // '운동 추가' 버튼 탭 시 임시 운동 추가 (추후 리액터와 연결 가능)
        footerView.addExcerciseButtonTapped
            .subscribe(with: self) { owner, _ in
                print("addExcerciseButtonTapped")
                owner.currentView.addExcercise(name: "Mock", setCount: 5)
            }.disposed(by: disposeBag)
        
        // '루틴 저장' 버튼 탭 시 처리 로직 (현재는 print만)
        footerView.saveRoutineButtonTapped
            .subscribe(with: self) { owner, _ in
                print("saveRoutineButtonTapped")
            }.disposed(by: disposeBag)
        
        // 화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .bind { [weak self] _ in
                guard let self else { return }
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI Methods
private extension EditExcerciseViewController {
    
    /// 전체 UI 구성 메서드
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
    }
    
    /// 배경색 설정 등 외형 설정
    func setAppearance() {
        view.backgroundColor = .background
    }
    
    /// 뷰 계층 구성: 스크롤뷰 및 내부 요소, 푸터 뷰 추가
    func setViewHierarchy() {
        scrollView.addSubviews(
            headerView,
            headerBorderLineView,
            contentView,
            contentBorderLineView,
            currentView
        )
        
        view.addSubviews(scrollView, footerView)
    }
    
    /// SnapKit을 이용한 오토레이아웃 구성
    func setConstraints() {
        headerView.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.width.equalToSuperview()
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
        }
        
        contentBorderLineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.top.equalTo(contentView.snp.bottom).offset(20)
        }
        
        currentView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(contentBorderLineView.snp.bottom).offset(32)
            $0.bottom.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(footerView.snp.top)
        }
        
        footerView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalToSuperview().multipliedBy(0.1125) // 약 1/9 높이
        }
    }
}
