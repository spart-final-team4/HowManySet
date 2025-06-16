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
    private lazy var mainVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
    }
    
    private lazy var topContentsHStack = UIStackView().then {
        $0.axis = .horizontal
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
        self.addSubview(mainVStack)
        mainVStack.addArrangedSubviews(topContentsHStack, containerView, routineSelectButton)
        topContentsHStack.addArrangedSubviews(todayDateLabel)
        containerView.addSubviews(initialImageView, initialTextLabel)
    }
    
    func setConstraints() {
        mainVStack.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.verticalEdges.equalToSuperview().inset(28)
        }
        
        topContentsHStack.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        containerView.snp.makeConstraints {
            $0.height.equalTo(self.snp.height).multipliedBy(0.55)
        }
        
        initialImageView.snp.makeConstraints {
            $0.top.equalTo(containerView).inset(50)
            $0.centerX.equalToSuperview()
        }
        
        initialTextLabel.snp.makeConstraints {
            $0.top.equalTo(initialImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        routineSelectButton.snp.makeConstraints {
            $0.height.equalTo(60)
        }
    }
}

// MARK: Internal Methods
extension HomeRoutineStartCardView {

}
