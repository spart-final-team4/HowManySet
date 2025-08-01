import UIKit
import SnapKit
import Then

final class MemoInfoCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "MemoInfoCell"
    private let placeholderText = String(localized: "메모를 입력해주세요.")

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
    func configure(comment: String?) {
        let isEmpty = comment?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        memoTextView.text = isEmpty ? placeholderText : comment
        memoTextView.textColor = isEmpty ? .grey3 : .white
        memoTextView.layer.borderWidth = 0
        
        print("configure - comment: \(comment ?? "nil")")
        print("❓ placeholder 적용됐는지: \(isEmpty)")
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
            $0.text = String(localized: "메모")
            $0.textColor = .white
            $0.font = .pretendard(size: 20, weight: .semibold)
            $0.textAlignment = .left
        }

        memoTextView.do {
            $0.backgroundColor = .bsInputFieldBG
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.font = .pretendard(size: 16, weight: .regular)
            $0.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)

            // 키보드 관련
            $0.autocorrectionType = .no // 자동 수정 끔
            $0.spellCheckingType = .no // 맞춤법 검사 끔
            $0.smartInsertDeleteType = .no // 스마트 삽입/삭제 끔
            $0.autocapitalizationType = .none // 영문으로 시작할 때 자동 대문자 끔
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

// MARK: - Computed Properties
extension MemoInfoCell {
    var publicMemoTextView: UITextView { memoTextView }
}
