import UIKit

protocol NumberTextFieldNavigatorDelegate: AnyObject {
    func didTappedPreviousButton(from textfield: NumberTextField)
    func didTappedNextButton(from textfield: NumberTextField)
}

public class NumberTextField: UITextField {
    
    weak var navigatorDelegate: NumberTextFieldNavigatorDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        
        let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTappedPreviousButton))
        let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTappedNextButton))
        let completeButton = UIBarButtonItem(title: "완료",
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTappedCompleteButton))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        
        toolbar.items = [previousButton, nextButton, flexSpace, completeButton]
        return toolbar
    }
    
    private func setAccessoryView() {
        self.inputAccessoryView = setToolbar()
    }
    
    private func configure() {
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
    }
    
    @objc func didTappedPreviousButton() {
        navigatorDelegate?.didTappedPreviousButton(from: self)
    }
    
    @objc func didTappedNextButton() {
        navigatorDelegate?.didTappedNextButton(from: self)
    }
    
    @objc func didTappedCompleteButton() {
        super.resignFirstResponder()
    }
}
