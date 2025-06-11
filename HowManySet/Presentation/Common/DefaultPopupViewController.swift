//
//  DefaultPopupViewController.swift
//  HowManySet
//
//  Created by MJ Dev on 6/12/25.
//

import UIKit
import Then
import SnapKit

final class DefaultPopupViewController: UIViewController {
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.backgroundColor = .bottomSheetBG
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        $0.distribution = .fillProportionally
        $0.layer.cornerRadius = 20
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .regular)
        $0.textColor = .error
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 2
        $0.textColor = .textTertiary
    }
    
    private let okButton = UIButton().then {
        $0.setTitleColor(.textTertiary, for: .normal)
        $0.backgroundColor = .error
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.addTarget(self, action: #selector(didTapOkButton), for: .touchUpInside)
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitleColor(.textTertiary, for: .normal)
        $0.backgroundColor = .clear
        $0.setTitle("취소", for: .normal)
        $0.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    private var okAction: (() -> Void)?
    
    override func viewDidLoad() {
        setupUI()
    }
    
    convenience init(title: String, content: String, okButtonText: String, okAction: @escaping () -> Void) {
        self.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
        self.titleLabel.text = title
        self.contentLabel.text = content
        self.okButton.setTitle(okButtonText, for: .normal)
        self.okAction = okAction
    }
    
    @objc private func didTapOkButton() {
        okAction?()
    }
    
    @objc private func didTapCancelButton() {
        self.dismiss(animated: true)
    }
}

private extension DefaultPopupViewController {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    func setAppearance() {
        view.backgroundColor = .black.withAlphaComponent(0.3)
    }
    func setViewHierarchy() {
        view.addSubviews(stackView)
        stackView.addArrangedSubviews(titleLabel, contentLabel, okButton, cancelButton)
    }
    func setConstraints() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.height.equalToSuperview().multipliedBy(0.3)
        }
    }
}
