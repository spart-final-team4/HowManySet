//
//  HomeRoutineStartCardView.swift
//  HowManySet
//
//  Created by 정근호 on 6/7/25.
//

import UIKit
import SnapKit
import Then

final class HomeRoutineStartCardView: UIView {
    
    // MARK: - Properties
    private let initialText = "오늘도 득근해요"
    private let selectButtonText = "운동 시작하기"
    
    // MARK: - UI Components
    private lazy var mainContentVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .fill
    }

    private lazy var spacer = UIView().then {
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    lazy var todayDateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .cardContentBG
        $0.layer.cornerRadius = 12
    }
    
    private lazy var containerVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }

    private lazy var initialImageView = UIImageView().then {
        $0.image = UIImage(named: "MainIcon")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var initialTextLabel = UILabel().then {
        $0.text = initialText
        $0.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        $0.numberOfLines = 1
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .center
    }
    
    lazy var routineSelectButton = UIButton().then {
        $0.backgroundColor = .brand
        $0.setTitle(selectButtonText, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        $0.titleLabel?.textColor = .black
        $0.layer.cornerRadius = 12
    }
        
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: UI Methods
private extension HomeRoutineStartCardView {
    func setupUI() {
        backgroundColor = .cardBackground
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        
        self.addSubviews(
            mainContentVStack,
            routineSelectButton
        )
        
        mainContentVStack.addArrangedSubviews(
            todayDateLabel,
            containerView,
            routineSelectButton
        )

        containerView.addSubview(containerVStack)
        containerVStack.addArrangedSubviews(initialImageView, initialTextLabel)
    }
    
    func setConstraints() {
        
        mainContentVStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        todayDateLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(mainContentVStack)
            $0.height.equalToSuperview().multipliedBy(0.55)
        }
        
        containerVStack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        routineSelectButton.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        initialImageView.snp.makeConstraints {
            $0.width.height.equalTo(70)
        }
    }
}
