import UIKit
import SnapKit
import Then
import FSCalendar

final class CalendarView: UIView {
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CalendarView {
    func setupUI() {
        self.backgroundColor = .black
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        titleLabel.do {
            $0.text = "기록"
            $0.font = .systemFont(ofSize: 36, weight: .regular)
            $0.textColor = .white
        }
    }

    func setViewHierarchy() {
        [
            titleLabel
        ].forEach { addSubviews($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.leading.equalTo(safeAreaLayoutGuide).offset(20)
        }
    }
}
