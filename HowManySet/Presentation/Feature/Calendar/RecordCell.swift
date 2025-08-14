import UIKit
import SnapKit
import Then

final class RecordCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "RecordCell"

    private let labelStackView = UIStackView()
    private let routineLabel = UILabel()
    private let setsLabel = UILabel()
    private let timeLabel = UILabel()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - configure
    /// WorkoutRecord의 데이터를 받아오는 메서드
    func configure(with record: WorkoutRecord) {
        // 루틴 이름
        routineLabel.text = record.workoutRoutine.name

        // 총 세트 수
        let totalSets = record.workoutRoutine.workouts.map { $0.sets.count }.reduce(0, +)
        setsLabel.text = String(format: String(localized: "총 %d세트"), totalSets)

        // 시작시간 ~ 종료시간
        let startTime = record.date.startTime(fromTotalTime: record.totalTime)
        let startStr = startTime.toTimeLabel()
        let endStr = record.date.toTimeLabel()

        // 총 시간, 총 운동시간
        let totalTimeLabel = record.totalTime.toMinutesLabel()
        let workoutTimeLabel = record.workoutTime.toMinutesLabel()
        
        let timeInfo = String(
            format: String(localized: "%@ ~ %@, 총 시간 %@, 총 운동시간 %@"),
            startStr, endStr, totalTimeLabel, workoutTimeLabel
        )
        timeLabel.text = timeInfo
    }
}

// MARK: - RecordCell UI 작업
private extension RecordCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
        setTableViewCellClearSetting()
    }

    func setAppearance() {
        contentView.do {
            $0.backgroundColor = #colorLiteral(red: 0.2697538137, green: 0.2697537839, blue: 0.2697538137, alpha: 1)
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }

        labelStackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 12
        }

        routineLabel.do {
            $0.textColor = .white
            $0.font = .pretendard(size: 20, weight: .semibold)
        }

        setsLabel.do {
            $0.textColor = .white
            $0.font = .pretendard(size: 14, weight: .regular)
        }

        timeLabel.do {
            $0.textColor = .white
            $0.font = .pretendard(size: 14, weight: .regular)
        }
    }

    func setViewHierarchy() {
        contentView.addSubview(labelStackView)

        [
            routineLabel,
            setsLabel,
            timeLabel
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

        // 셀 전체 배경을 clear하게 만듦
        backgroundColor = .clear

        // 셀 클릭 시 선택되었다고 셀 전체가 덮이는 것을 방지
        selectedBackgroundView = UIView().then {
            $0.backgroundColor = .clear
        }
    }
}
