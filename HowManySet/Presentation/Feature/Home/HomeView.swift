//
//  HomeView.swift
//  HowManySet
//
//  Created by 정근호 on 7/21/25.
//

import UIKit
import SnapKit
import Then

final class HomeView: UIView {
    
    // MARK: - Properties
    private let screenWidth = UIScreen.main.bounds.width
    private let cardInset: CGFloat = 20
    private let cardWidth = UIScreen.main.bounds.width - 40
    
    private let reactor: HomeViewReactor
    
    // MARK: - UI Components
    private lazy var topTimerHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
    }
    
    private lazy var workoutTimeLabel = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 36, weight: .bold)
    }
    
    private lazy var pauseButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 26), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    private lazy var buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .trailing
    }
    
    private lazy var stopButton = UIButton().then {
        $0.layer.cornerRadius = 26
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        $0.tintColor = .pauseButton
    }
    
    private lazy var forwardButton = UIButton().then {
        $0.layer.cornerRadius = 26
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    private lazy var cardContainer = UIView().then {
        $0.alpha = 0
    }
    
    private lazy var restInfoView = RestInfoView(frame: .zero, homeViewReactor: self.reactor).then {
        $0.backgroundColor = .cardBackground
        $0.layer.cornerRadius = 20
    }
    
    // MARK: - 페이징 스크롤 뷰 관련
    private lazy var pagingScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
    }
    
    private lazy var pageController = UIPageControl().then {
        $0.currentPage = 0
        $0.numberOfPages = 0
        $0.hidesForSinglePage = false
    }
    
    private lazy var pagingScrollContentView = UIView()
    
    
    // MARK: - Initializer
    init(frame: CGRect, reactor: HomeViewReactor) {
        self.reactor = reactor
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods
private extension HomeView {
    func setupUI() {
        backgroundColor = .background
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        addSubviews(
            topTimerHStackView,
            buttonHStackView,
            cardContainer,
            pagingScrollView,
            pageController,
            restInfoView
        )
        
        topTimerHStackView.addArrangedSubviews(
            workoutTimeLabel,
            pauseButton
        )
        
        buttonHStackView.addArrangedSubviews(
            stopButton,
            forwardButton
        )
        
        pagingScrollView.addSubview(pagingScrollContentView)
    }
    
    func setConstraints() {
        
        topTimerHStackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.equalTo(safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(cardContainer.snp.top).offset(-24)
        }
        
        buttonHStackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(cardContainer.snp.top).offset(-24)
        }
        
        stopButton.snp.makeConstraints {
            $0.width.height.equalTo(52)
        }
        
        forwardButton.snp.makeConstraints {
            $0.width.height.equalTo(52)
        }
        
        cardContainer.snp.makeConstraints {
            $0.top.equalTo(buttonHStackView.snp.bottom).offset(24)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            $0.height.equalToSuperview().multipliedBy(0.45)
        }
        
        pagingScrollView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.45)
        }
        
        pagingScrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        pageController.snp.makeConstraints {
            $0.top.equalTo(cardContainer.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        restInfoView.snp.makeConstraints {
            $0.top.equalTo(pageController.snp.bottom).offset(6)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.15)
        }
    }
}

// MARK: - Internal Methods
extension HomeView {
    /// 스크롤 뷰 기준으로 레이아웃 재설정
    func remakeOtherViewsWithScrollView() {
        
        topTimerHStackView.snp.remakeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.equalTo(safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(pagingScrollView.snp.top).offset(-32)
        }
        
        buttonHStackView.snp.remakeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(pagingScrollView.snp.top).offset(-32)
        }
        
        pageController.snp.remakeConstraints {
            $0.top.equalTo(pagingScrollView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
}
