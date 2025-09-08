import UIKit

public class NumberTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
}
