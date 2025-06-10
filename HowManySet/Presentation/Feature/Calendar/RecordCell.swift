import UIKit
import SnapKit
import Then

final class RecordCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "RecordCell"

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
        setsLabel.text = "총 \(totalSets)세트"

        // 시작시간 ~ 종료시간
        let startTime = record.date.startTime(fromTotalTime: record.totalTime)
        let startStr = startTime.toTimeLabel()
        let endStr = record.date.toTimeLabel()

        // 총 시간, 총 운동시간
        let totalTimeLabel = record.totalTime.toMinutesLabel()
        let workoutTimeLabel = record.workoutTime.toMinutesLabel()

        timeLabel.text = "\(startStr) ~ \(endStr), 총 시간 \(totalTimeLabel), 총 운동시간 \(workoutTimeLabel)"
    }
}

// MARK: - RecordCell UI 작업
private extension RecordCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        // 셀 선택 시 배경색 변화 없음
        selectionStyle = .none

        contentView.do {
            $0.backgroundColor = .cardBackground
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }

        routineLabel.do {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 20, weight: .semibold)
        }

        setsLabel.do {
            $0.textColor = .textSecondary
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }

        timeLabel.do {
            $0.textColor = .textSecondary
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }
    }

    func setViewHierarchy() {
        [
            routineLabel,
            setsLabel,
            timeLabel
        ].forEach { addSubviews($0) }
    }

    func setConstraints() {
        routineLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        setsLabel.snp.makeConstraints {
            $0.top.equalTo(routineLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        timeLabel.snp.makeConstraints {
            $0.top.equalTo(setsLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
}
