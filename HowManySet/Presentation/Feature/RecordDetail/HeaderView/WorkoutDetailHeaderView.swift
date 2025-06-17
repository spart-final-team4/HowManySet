import UIKit
import SnapKit
import Then

final class WorkoutDetailHeaderView: UICollectionReusableView {
    static let identifier = "WorkoutDetailHeaderView"

    private let titleLabel = UILabel()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

// MARK: - WorkoutDetailHeaderView UI 관련 extension
private extension WorkoutDetailHeaderView {
    func setupUI() {
        backgroundColor = .clear
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        titleLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .white
        }
    }

    func setViewHierarchy() {
        addSubview(titleLabel)
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.verticalEdges.equalToSuperview().inset(4)
        }
    }
}
