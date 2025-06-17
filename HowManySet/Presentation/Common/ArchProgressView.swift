//
//  ArchProgressView.swift
//  HowManySet
//
//  Created by 정근호 on 6/16/25.
//

import UIKit
import SnapKit
import Then

final class ArchProgressView: UIView {
    
    // MARK: - Properties
    var progress: CGFloat = 0.0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }
    
    var trackColor: UIColor = UIColor.systemGray4 {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progressColor: UIColor = UIColor.brand {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var lineWidth: CGFloat = 22 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
        }
    }
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
        
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayers()
    }
}

// MARK: - UI Methods
private extension ArchProgressView {
    
    func setupUI() {
        backgroundColor = .clear
        
        setupLayers()
    }
    
    func setupLayers() {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height * 2) / 2 - lineWidth / 2

        // 시작 각도: 왼쪽 아래 (180도)
        // 끝 각도: 오른쪽 아래 (360도)
        // -> 라디언으로 변환
        let startAngle = CGFloat(180 * Double.pi / 180)
        let endAngle = CGFloat(360 * Double.pi / 180)
        
        let arcPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        // Track Layer (배경)
        trackLayer.removeFromSuperlayer()
        trackLayer.path = arcPath.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // Progress Layer (진행 상태)
        progressLayer.removeFromSuperlayer()
        progressLayer.path = arcPath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
    }
}

// MARK: - Public Methods
extension ArchProgressView {
    
    /// 애니메이션과 함께 프로그레스 설정
    func setProgress(_ progress: CGFloat, animated: Bool = true, duration: TimeInterval = 1.0) {
        let clampedProgress = max(0, min(1, progress))
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = self.progress
            animation.toValue = clampedProgress
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            progressLayer.add(animation, forKey: "progressAnimation")
            
            // 라벨 애니메이션
            UIView.animate(withDuration: duration) { [weak self] in
                self?.progress = clampedProgress
            }
        } else {
            self.progress = clampedProgress
        }
    }
}
