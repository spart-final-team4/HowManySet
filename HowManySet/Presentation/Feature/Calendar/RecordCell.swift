import UIKit
import SnapKit
import Then

final class RecordCell: UITableViewCell {
    static let identifier = "RecordCell"

    private let routineLabel = UILabel()
    private let detailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(routine: String, detail: String) {
        routineLabel.text = routine
        detailLabel.text = detail
    }
}

private extension RecordCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        contentView.do {
            $0.backgroundColor = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1.0)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }

        routineLabel.do {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 20, weight: .semibold)
        }

        detailLabel.do {
            $0.textColor = .lightGray
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }
    }

    func setViewHierarchy() {
        [
            routineLabel,
            detailLabel
        ].forEach { addSubviews($0) }
    }

    func setConstraints() {
        routineLabel.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(12)
        }

        detailLabel.snp.makeConstraints {
            $0.top.equalTo(routineLabel.snp.bottom).offset(4)
            $0.horizontalEdges.bottom.equalToSuperview().inset(12)
        }
    }
}
