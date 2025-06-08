//
//  HomeRoutineStartView.swift
//  HowManySet
//
//  Created by 정근호 on 6/7/25.
//

import UIKit
import SnapKit
import Then

final class HomeRoutineStartView: UIView {
    
    // MARK: - Properties
    private let todayDate = "06.05"
    private let initialText = "오늘도 득근해요"
    private let selectButtonText = "운동 시작하기"
    
    // MARK: - UI Components
    private lazy var mainVStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.distribution = .equalSpacing
    }
    
    private lazy var topContentsHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
    }
    
    private lazy var spacer = UIView().then {
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private lazy var todayDateLabel = UILabel().then {
        $0.text = todayDate
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    private lazy var optionButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .label
    }

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 20
    }
    
    private lazy var initialImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        $0.image = UIImage(systemName: "dumbbell", withConfiguration: config)
        $0.tintColor = .brand
    }
    
    private lazy var initialTextLabel = UILabel().then {
        $0.text = initialText
        $0.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        $0.numberOfLines = 0
    }
    
    private lazy var routineSelectButton = UIButton().then {
        $0.backgroundColor = .brand
        $0.setTitle(selectButtonText, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.titleLabel?.textColor = .black
        $0.layer.cornerRadius = 20
    }
        
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: UI Methods
private extension HomeRoutineStartView {
    func setupUI() {
        backgroundColor = .systemGray6
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        self.addSubview(mainVStack)
        mainVStack.addArrangedSubviews(topContentsHStack, containerView, routineSelectButton)
        topContentsHStack.addArrangedSubviews(todayDateLabel, spacer, optionButton)
        containerView.addSubviews(initialImageView, initialTextLabel)
    }
    
    func setConstraints() {
        mainVStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        topContentsHStack.snp.makeConstraints {
            $0.top.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.height.equalTo(self.snp.height).multipliedBy(0.5)
        }
        
        initialImageView.snp.makeConstraints {
            $0.top.equalTo(containerView).inset(40)
            $0.centerX.equalToSuperview()
        }
        
        initialTextLabel.snp.makeConstraints {
            $0.top.equalTo(initialImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        routineSelectButton.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
    }
}
