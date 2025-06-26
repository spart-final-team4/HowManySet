//
//  EditExcerciseHeaderView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/15/25.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift

/// 운동 이름을 입력받는 화면 상단 헤더 뷰입니다.
///
/// `UILabel`과 `UITextField`로 구성되어 있으며, 사용자가 운동명을 입력하면
/// 내부적으로 `exerciseNameRelay`를 통해 Reactive하게 해당 값을 전달합니다.
final class EditExcerciseHeaderView: UIView {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    /// 사용자 입력 운동명을 바인딩하는 Relay입니다.
    ///
    /// 외부에서는 읽기만 가능하며, 내부 텍스트 필드 변경 시 자동으로 값이 업데이트됩니다.
    private(set) var exerciseNameRelay = BehaviorRelay<String>(value: "")
    
    /// 운동명 입력 안내 문구를 보여주는 라벨입니다.
    private let titleLabel = UILabel().then {
        $0.text = "운동명을 입력해주세요"
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .textSecondary
    }
    
    /// 사용자로부터 운동명을 입력받는 텍스트 필드입니다.
    ///
    /// 왼쪽에 패딩이 있으며, 둥근 테두리 및 배경색이 적용되어 있습니다.
    private let exerciseNameTextField = UITextField().then {
        $0.placeholder = "예) 벤치프레스, 체스트 프레스"
        $0.backgroundColor = .bottomSheetBG
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: $0.frame.height))
        $0.leftView = paddingView
        $0.leftViewMode = .always
    }
    
    // MARK: - Initializers
    
    /// 코드 기반으로 초기화될 때 호출됩니다.
    /// - Parameter frame: 뷰의 초기 프레임
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 스토리보드/인터페이스 빌더 초기화는 지원하지 않습니다.
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    /// 텍스트 필드 및 Relay를 초기 상태로 되돌립니다.
    func returnInitialState() {
        self.exerciseNameTextField.text = ""
        exerciseNameRelay.accept("")
    }
}

// MARK: - Private UI Methods

private extension EditExcerciseHeaderView {
    
    /// 전체 UI 구성 메서드입니다.
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
        bind()
    }
    
    /// 내부 바인딩 설정 메서드입니다.
    ///
    /// 텍스트 필드 변경을 `exerciseNameRelay`에 바인딩합니다.
    func bind() {
        exerciseNameTextField.rx.text
            .do(onNext: { str in
                print("exerciseNameTextField.rx.text")
            })
            .compactMap { $0 }
            .distinctUntilChanged()
            .bind(to: exerciseNameRelay)
            .disposed(by: disposeBag)
    }
    
    /// 배경색 등 외형을 설정합니다.
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 서브뷰를 계층에 추가합니다.
    func setViewHierarchy() {
        self.addSubviews(titleLabel, exerciseNameTextField)
    }
    
    /// 오토레이아웃 제약 조건을 설정합니다.
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(8)
        }
        
        exerciseNameTextField.snp.makeConstraints {
            $0.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.height.equalTo(56)
        }
    }
}

// MARK: Internal Methods
extension EditExcerciseHeaderView {
    
    func configure(with text: String) {
        exerciseNameTextField.text = text
    }
    
    func editConfigure(with text: String) {
        if text == exerciseNameTextField.text { return }
        exerciseNameTextField.text = text
        titleLabel.text = "운동 이름"
    }
}
