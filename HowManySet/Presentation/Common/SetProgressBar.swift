//
//  SetProgressBar.swift
//  HowManySet
//
//  Created by 정근호 on 6/6/25.
//

import UIKit
import SnapKit
import RxSwift

final class SetProgressBarView: UIView {
    
    // MARK: - Properties
    private var progressBarSpacing: CGFloat = 2
    private let completedColor: UIColor = .brand
    private let remainingColor: UIColor = .gray
    
    // 테스트 위해 임의로 지정
    var totalSets = 5 {
        didSet {
            setupSegments()
        }
    }
    
    // 테스트 위해 임의로 지정
    var currentSet = 2 {
        didSet {
            updateProgress()
        }
    }
    
    // MARK: - UI Components
    /// 양 끝 부분만 round 처리하기 위한 View
    private let roundedContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    // LiveActivity에 Then 추가 안하기 위해 Then 사용 안하였음
    /// 세트 진행상황 Progress Bar
    private lazy var progressBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = progressBarSpacing
        return stackView
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: UI Methods
private extension SetProgressBarView {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
        setupSegments()
    }
    
    func setViewHiearchy() {
        self.addSubview(roundedContainerView)
        roundedContainerView.addSubview(progressBarStackView)
    }
    
    func setConstraints() {
        roundedContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        progressBarStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupSegments() {
        // 기존 세그먼트 뷰 모두 제거
        progressBarStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for _ in (0..<totalSets) {
            
            let segmentView = UIView()
            segmentView.backgroundColor = remainingColor
            
            progressBarStackView.addArrangedSubview(segmentView)
            segmentView.snp.makeConstraints {
                $0.width.equalTo(progressBarStackView.snp.width).multipliedBy(1/totalSets)
                $0.height.equalToSuperview()
            }
        }
        updateProgress()
    }
    
    func updateProgress() {
        // currentSet에 따라 각 세그먼트 뷰의 색상 변경
        for (index, segmentView) in progressBarStackView.arrangedSubviews.enumerated() {
       
           if index < self.currentSet {
                segmentView.backgroundColor = self.completedColor
           } else {
               break
           }
       }
    }
}

// MARK: Internal Methods
extension SetProgressBarView {
    func setProgress(totalSets: Int, currentSet: Int) {
        self.totalSets = totalSets
        self.currentSet = currentSet
        updateProgress()
    }
}
