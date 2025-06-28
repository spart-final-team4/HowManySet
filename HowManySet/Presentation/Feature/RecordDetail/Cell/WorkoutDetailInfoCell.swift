import UIKit
import SnapKit
import Then

final class WorkoutDetailInfoCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "WorkoutDetailInfoCell"

    // 세트 정보 setVStack을 수평으로 묶어놓은 stackView
    private let setInfoStackView = UIStackView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - configure
    /// Workout의 데이터를 받아오는 메서드
    func configure(index: Int, set: WorkoutSet) {
        // 기존 스택뷰 지우고 시키고 새롭게 시작
        setInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let setCountLabel = UILabel().then {
            $0.text = "\(index + 1)세트"
            $0.font = .pretendard(size: 12, weight: .regular)
            $0.textColor = .grey2
            $0.textAlignment = .center
        }

        let setDetailLabel = UILabel().then {
            $0.text = "\(set.weight.clean)\(set.unit) * \(set.reps)회"
            $0.font = .pretendard(size: 14, weight: .regular)
            $0.textColor = .grey4
            $0.textAlignment = .center
        }

        let setVStack = UIStackView(arrangedSubviews: [setCountLabel, setDetailLabel]).then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 8
        }

        setInfoStackView.addArrangedSubview(setVStack)
    }
}

// MARK: - WorkoutDetailInfoCell UI 관련 extension
private extension WorkoutDetailInfoCell {
    func setupUI() {
        backgroundColor = .clear
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        setInfoStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .fill
        }
    }

    func setViewHierarchy() {
        contentView.addSubviews(setInfoStackView)
    }

    func setConstraints() {
        setInfoStackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}
