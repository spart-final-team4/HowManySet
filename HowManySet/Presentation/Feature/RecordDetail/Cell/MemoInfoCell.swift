import UIKit
import SnapKit
import Then

final class MemoInfoCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "MemoInfoCell"

    private let memoTitleLabel = UILabel()
    private let memoTextView = UITextView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - configure
    /// WorkoutRecord의 데이터를 받아오는 메서드
    func configure(comment: String?) {
        memoTextView.text = (comment?.isEmpty == false) ? comment : "메모를 입력해주세요."
        memoTextView.textColor = (comment?.isEmpty == false) ? .white : .systemGray
    }
}

// MARK: - MemoInfoCell UI 관련 extension
private extension MemoInfoCell {
    func setupUI() {
        backgroundColor = .clear
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        memoTitleLabel.do {
            $0.text = "메모"
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 20, weight: .semibold)
            $0.textAlignment = .left
        }

        memoTextView.do {
            $0.backgroundColor = .bsInputFieldBG
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.font = .systemFont(ofSize: 16, weight: .regular)
            $0.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        }
    }

    func setViewHierarchy() {
        contentView.addSubviews(memoTitleLabel, memoTextView)
    }

    func setConstraints() {
        memoTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.horizontalEdges.equalToSuperview()
        }

        memoTextView.snp.makeConstraints {
            $0.top.equalTo(memoTitleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(180)
        }
    }
}
