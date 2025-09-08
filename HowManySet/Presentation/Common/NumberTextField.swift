import UIKit

public class NumberTextField: UITextField {
    
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
                                             action: nil)
        let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"),
                                         style: .plain,
                                         target: self,
                                         action: nil)
        let completeButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: nil)
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
}
