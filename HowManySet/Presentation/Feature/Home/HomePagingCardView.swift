//
//  HomeView.swift
//  HowManySet
//
//  Created by 정근호 on 6/7/25.
//

import UIKit
import SnapKit
import Then

final class HomePagingCardView: UIView {
    
    // MARK: - Properties
    private let setCompleteText = "세트 완료"
    private let restText = "휴식도 운동이에요"
    
    // MARK: - UI Components
    private lazy var mainVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
    }
    
    private lazy var topInfoHStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    private lazy var spacer = UIView().then {
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private lazy var exerciseInfoHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
    }
    
    private lazy var exerciseNameLabel = UILabel().then {
        $0.text = "랫풀다운"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private lazy var exerciseSetLabel = UILabel().then {
        $0.text = "1 / 5"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .textSecondary
    }

    private lazy var optionButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .label
    }
    
    private lazy var setProgressBar = SetProgressBarView().then {
        $0.backgroundColor = .cardBackground
    }
    
    private lazy var currentSetLabel = UILabel().then {
        $0.text = "1 세트"
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .cardContentBG
        $0.layer.cornerRadius = 12
    }
    
    private lazy var weightRepsHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 70
    }
    
    private lazy var weightInfoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private lazy var weightImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        $0.image = UIImage(systemName: "dumbbell", withConfiguration: config)
        $0.tintColor = .brand
    }
    
    private lazy var weightLabel = UILabel().then {
        $0.text = "60kg"
        $0.font = .systemFont(ofSize: 24)
        $0.textColor = .white
    }
    
    private lazy var repsInfoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private lazy var repsImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        $0.image = UIImage(systemName: "dumbbell", withConfiguration: config)
        $0.tintColor = .brand
    }
    
    private lazy var repsLabel = UILabel().then {
        $0.text = "10회"
        $0.font = .systemFont(ofSize: 24)
        $0.textColor = .white
    }
    
    lazy var setCompleteButton = UIButton().then {
        $0.backgroundColor = .brand
        $0.setTitle(setCompleteText, for: .normal)
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
private extension HomePagingCardView {
    func setupUI() {
        backgroundColor = .cardBackground
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        self.addSubview(mainVStack)
        
        mainVStack.addArrangedSubviews(
            topInfoHStack,
            setProgressBar,
            currentSetLabel,
            containerView,
            setCompleteButton
        )

        topInfoHStack.addArrangedSubviews(exerciseInfoHStack, spacer, optionButton)
        exerciseInfoHStack.addArrangedSubviews(exerciseNameLabel, exerciseSetLabel)
        containerView.addSubview(weightRepsHStack)
        weightRepsHStack.addArrangedSubviews(weightInfoVStack, repsInfoVStack)
        weightInfoVStack.addArrangedSubviews(weightImageView, weightLabel)
        repsInfoVStack.addArrangedSubviews(repsImageView, repsLabel)
    }
    
    func setConstraints() {
        mainVStack.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.verticalEdges.equalToSuperview().inset(28)
        }
                
        setProgressBar.snp.makeConstraints {
            $0.height.equalTo(12)
        }
        
        containerView.snp.makeConstraints {
            $0.height.equalTo(self.snp.height).multipliedBy(0.39)
        }
    
        weightRepsHStack.snp.makeConstraints {
            $0.height.equalTo(containerView.snp.height).multipliedBy(0.5)
            $0.centerX.centerY.equalToSuperview()
        }
        
        setCompleteButton.snp.makeConstraints {
            $0.height.equalTo(60)
        }
    }
}

// MARK: Internal Methods
extension HomeRoutineStartCardView {

}


