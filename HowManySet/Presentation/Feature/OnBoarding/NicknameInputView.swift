//
//  NicknameInputView.swift
//  HowManySet
//
//  Created by GO on 6/13/25.
//

import UIKit
import SnapKit
import Then

/**
 온보딩/회원가입 등에서 닉네임 입력을 위한 사용자 정의 UIView.

 - 주요 UI 구성:
    - 상단 안내 타이틀(UILabel)
    - 닉네임 입력 필드(UITextField)
    - 하단 "다음" 버튼(UIButton)

 - 특징:
    - SnapKit을 이용한 오토레이아웃 적용
    - Then 라이브러리로 UI 요소 선언 및 속성 초기화
    - placeholder, 버튼 활성화 등 UX 디테일 반영
    - MVVM 또는 ReactorKit 구조에서 View 역할만 담당하며, 상태/이벤트 처리는 ViewController 또는 ViewModel에서 수행
    - 추후 접근제어자(private/public) 및 인터페이스는 캡슐화 요구에 따라 변경 가능

 - 사용 예시:
    ```
    let nicknameInputView = NicknameInputView()
    // ViewController에서 addSubview 및 레이아웃 설정 후 사용
    // 닉네임 유효성 체크 및 버튼 활성화는 VC/VM에서 바인딩
    ```
 */
final class NicknameInputView: UIView {
    
    /// 닉네임 입력 안내 타이틀 라벨. 상단에 위치.
    private let titleLabel = UILabel().then {
        $0.text = "닉네임을 적어주세요"
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textColor = .white
        $0.textAlignment = .left
    }
    
    /// 닉네임 입력 텍스트필드. 좌측 패딩, placeholder, 스타일 적용.
    let nicknameTextField = UITextField().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .white
        $0.backgroundColor = .darkGray
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.attributedPlaceholder = NSAttributedString(
            string: "한글, 영문 2~8자",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
        
        $0.autocorrectionType = .no // 자동 수정 끔
        $0.spellCheckingType = .no // 맞춤법 검사 끔
        $0.smartInsertDeleteType = .no // 스마트 삽입/삭제 끔
        $0.autocapitalizationType = .none // 자동 대문자 변환 끔
    }
    
    /// 하단 "다음" 버튼. 기본 비활성화 상태, 유효성 통과 시 활성화.
    /// 추후 접근제어자(private/public) 변경 예정.
    let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.isEnabled = false
        $0.backgroundColor = .darkGray
        $0.setTitleColor(.lightGray, for: .normal)
    }
    
    /// nextButton 제약조건 (키보드 대응용)
    private var nextButtonConstraint: Constraint?

    /**
     닉네임 입력 뷰를 초기화하고 UI 요소를 배치합니다.
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 키보드 높이에 따라 버튼 위치만 조정
    /// - Parameter keyboardHeight: 키보드 높이 (0이면 원래 위치로 복원)
    func adjustButtonForKeyboard(keyboardHeight: CGFloat) {
        let bottomInset = keyboardHeight > 0 ? keyboardHeight + 20 : 28
        nextButtonConstraint?.update(inset: bottomInset)
    }
}

// MARK: - UI 구성 및 레이아웃 설정
private extension NicknameInputView {
    /// 전체 UI 구성(색상, 계층, 제약조건) 설정
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 배경색 등 Appearance 설정
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 서브뷰 계층 구조 설정
    func setViewHierarchy() {
        self.addSubviews(titleLabel, nicknameTextField, nextButton)
    }
    
    /// SnapKit을 활용한 오토레이아웃 제약조건 설정
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(32)
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
        }
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        nextButton.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            nextButtonConstraint = $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(28).constraint
        }
    }
}
