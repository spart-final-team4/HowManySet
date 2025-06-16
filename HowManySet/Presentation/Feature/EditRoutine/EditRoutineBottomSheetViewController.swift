//
//  EditRoutineBottomSheetViewController.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit
import SnapKit
import Then

final class EditRoutineBottomSheetViewController: UIViewController {
    
    private lazy var excerciseChangeButton = UIButton().then {
        $0.setTitle("운동 정보 변경", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.titleLabel?.textColor = .textTertiary
        $0.contentHorizontalAlignment = .leading
        $0.contentEdgeInsets = .init(top: 13, left: 12, bottom: 13, right: 12)
        $0.backgroundColor = .disabledButton
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private lazy var removeExcerciseButton = UIButton().then {
        $0.setTitle("선택 운동 삭제", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.titleLabel?.textColor = .textTertiary
        $0.contentHorizontalAlignment = .leading
        $0.contentEdgeInsets = .init(top: 13, left: 12, bottom: 13, right: 12)
        $0.backgroundColor = .disabledButton
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private lazy var changeExcerciseListButton = UIButton().then {
        $0.setTitle("목록 순서 변경", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.titleLabel?.textColor = .textTertiary
        $0.contentHorizontalAlignment = .leading
        $0.contentEdgeInsets = .init(top: 13, left: 12, bottom: 13, right: 12)
        $0.backgroundColor = .disabledButton
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 12
        $0.addArrangedSubviews(excerciseChangeButton, removeExcerciseButton, changeExcerciseListButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
}

private extension EditRoutineBottomSheetViewController {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        view.backgroundColor = .background
    }
    func setViewHierarchy() {
        view.addSubviews(stackView)
    }
    func setConstraints() {
        stackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.height.equalTo(150)
        }
    }
}
