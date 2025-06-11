//
//  WorkoutOptionViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/5/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import ReactorKit

final class WorkoutOptionViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private let editText = "편집"
    private let editRoutineButtonText = "운동 목록 변경"
    private let memoText = "메모"
    private let memoPlaceHolderText = "메모를 입력해주세요."
    
    // MARK: - UI Components
    private lazy var containerView = UIView()
    
    private lazy var editLabel = UILabel().then {
        $0.text = editText
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    private lazy var editRoutineButton = UIButton().then {
        $0.backgroundColor = .disabledButton
        $0.layer.cornerRadius = 12
        $0.setTitle(editRoutineButtonText, for: .normal)
    }
    
    private lazy var memoLabel = UILabel().then {
        $0.text = memoText
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    private lazy var memoTextView = UITextView().then {
        $0.insertDictationResultPlaceholderText = memoPlaceHolderText
        $0.backgroundColor = .bsInputFieldBG
    }
    
    
    // MARK: - Initializer
    init(reactor: WorkoutOptionViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
}

// MARK: - UI Methods
private extension WorkoutOptionViewController {
    
    func setupUI() {
        
    }
    
    func setViewHiearchy() {
        
    }
    
    func setConstraints() {
        
    }
}

// MARK: - Reactor Binding
extension WorkoutOptionViewController {
    
    func bind(reactor: WorkoutOptionViewReactor) {
        
    }
}
