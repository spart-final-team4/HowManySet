import UIKit
import SnapKit
import Then

final class RoutineCell: UITableViewCell {
    static let identifier = "RoutineCell"

    // MARK: - UI Components
    private let labelStackView = UIStackView()
    private let nameLabel = UILabel()
    private let totalWorkoutsLabel = UILabel()
    private let totalSetsLabel = UILabel()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(with routine: WorkoutRoutine) {
        // 루틴명
        nameLabel.text = routine.name

        // 종목 수
        totalWorkoutsLabel.text = "종목 수: \(routine.workouts.count)"

        // 총 세트 수 계산
        let totalSets = routine.workouts.flatMap { $0.sets }.count
        totalSetsLabel.text = "총 세트 수: \(totalSets)"
    }
}

// MARK: - RoutineCell UI 작업
private extension RoutineCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
        setTableViewCellClearSetting()
    }

    func setAppearance() {
        contentView.do {
            $0.backgroundColor = .cardBackground
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }

        labelStackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 12
        }

        nameLabel.do {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 20, weight: .semibold)
        }

        totalWorkoutsLabel.do {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }

        totalSetsLabel.do {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }
    }

    func setViewHierarchy() {
        contentView.addSubview(labelStackView)

        [
            nameLabel,
            totalWorkoutsLabel,
            totalSetsLabel
        ].forEach { labelStackView.addArrangedSubview($0) }
    }

    func setConstraints() {
        contentView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }

        labelStackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }

    ///UITableViewCell에서 clear하게 setting하여 깔끔하게 보여주는 UI
    func setTableViewCellClearSetting() {
        // 셀 선택 시 배경색 변화 없음
        selectionStyle = .none

        // 셀 전체 배경 clear
        backgroundColor = .clear

        // 클릭 시 셀 전체 덮는 것 방지
        selectedBackgroundView = UIView().then {
            $0.backgroundColor = .clear
        }
    }
}
