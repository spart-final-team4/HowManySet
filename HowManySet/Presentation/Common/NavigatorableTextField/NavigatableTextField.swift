import UIKit

final class NavigatableTextField: UITextField {
    weak var navigator: TextFieldNavigator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        
        let previousButton = UIButton(type: .system)
        previousButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previousButton.sizeToFit()
        previousButton.addTarget(self, action: #selector(didTappedPreviousButton), for: .touchUpInside)

        let nextButton = UIButton(type: .system)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.sizeToFit()
        nextButton.addTarget(self, action: #selector(didTappedNextButton), for: .touchUpInside)

        let completeButton = UIButton(type: .system)
        completeButton.setTitle("완료", for: .normal)
        completeButton.sizeToFit()
        completeButton.addTarget(self, action: #selector(didTappedCompleteButton), for: .touchUpInside)

        let previousItem = UIBarButtonItem(customView: previousButton)
        let nextItem = UIBarButtonItem(customView: nextButton)
        let completeItem = UIBarButtonItem(customView: completeButton)

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [previousItem, nextItem, flexSpace, completeItem]
        
        return toolbar
    }
    
    private func setAccessoryView() {
        self.inputAccessoryView = setToolbar()
    }
    
    func configureNumberTextField() -> NavigatableTextField {
        placeholder = String(localized: "입력")
        backgroundColor = .bottomSheetBG
        clipsToBounds = true
        layer.cornerRadius = 12
        textColor = .white
        font = .pretendard(size: 16, weight: .regular)
        keyboardType = .decimalPad
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.height))
        leftView = paddingView
        leftViewMode = .always
        
        setAccessoryView()
        return self
    }
    
    func configureDefaultTextField() -> NavigatableTextField {
        placeholder = String(localized: "예) 벤치프레스, 체스트 프레스")
        backgroundColor = .bottomSheetBG
        clipsToBounds = true
        layer.cornerRadius = 12
        font = .pretendard(size: 16, weight: .regular)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.height))
        leftView = paddingView
        leftViewMode = .always

        // 키보드 관련
        autocorrectionType = .no // 자동 수정 끔
        spellCheckingType = .no // 맞춤법 검사 끔
        smartInsertDeleteType = .no // 스마트 삽입/삭제 끔
        autocapitalizationType = .none // 영문으로 시작할 때 자동 대문자 끔
        
        setAccessoryView()
        return self
    }
    
    
    @objc func didTappedPreviousButton() {
        navigator?.didTappedPreviousButton(from: self)
    }
    
    @objc func didTappedNextButton() {
        navigator?.didTappedNextButton(from: self)
    }
    
    @objc func didTappedCompleteButton() {
        super.resignFirstResponder()
    }
    
}
