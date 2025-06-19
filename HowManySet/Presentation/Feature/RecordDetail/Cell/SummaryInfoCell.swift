import UIKit
import SnapKit
import Then

final class SummaryInfoCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "SummaryInfoCell"

    private let headerHStackView = UIStackView()
    private let routineNameLabel = UILabel()
    private let saveButton = UIButton()
    private let confirmButton = UIButton()
    private let headerVStackView = UIStackView()
    private let startToEndLabel = UILabel()

    private let totalSummaryStackView = UIStackView()

    private let dividerView = UIView()

    private let workoutDetailTitleLabel = UILabel()

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
    func configure(with record: WorkoutRecord) {
        // 루틴명
        routineNameLabel.text = record.workoutRoutine.name

        // 시작~종료 시간
        let endTime = record.date
        let startTime = endTime.startTime(fromTotalTime: record.totalTime)
        startToEndLabel.text = "\(startTime.toTimeLabel()) ~ \(endTime.toTimeLabel())"

        // summary stack (기존 항목 제거 후 재구성)
        totalSummaryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let totalSets = record.workoutRoutine.workouts.flatMap { $0.sets }.count
        let totalReps = record.workoutRoutine.workouts.flatMap { $0.sets.map { $0.reps } }.reduce(0, +)

        let summaries: [(String, String)] = [
            ("총 시간", record.totalTime.toMinutesLabel()),
            ("순 운동", record.workoutTime.toMinutesLabel()),
            ("운동 종목", "\(record.workoutRoutine.workouts.count)종목"),
            ("세트 수", "\(totalSets)세트"),
            ("반복 수", "\(totalReps)회")
        ]

        for (title, value) in summaries {
            totalSummaryStackView.addArrangedSubview(makeTotalVStackView(title: title, value: value))
        }
    }
}

// MARK: - Computed Properties
extension SummaryInfoCell {
    var publicConfirmButton: UIButton { confirmButton }
    var publicSaveButton: UIButton { saveButton }
}

// MARK: - SummaryInfoCell UI 관련 extension
private extension SummaryInfoCell {
    func setupUI() {
        backgroundColor = .clear
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        // 첫번째
        headerHStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        routineNameLabel.do {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 18, weight: .semibold)
            $0.textAlignment = .center
        }
        saveButton.do {
            $0.setTitle("저장", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.setTitleColor(.textTertiary, for: .normal)
        }
        confirmButton.do {
            $0.setTitle("확인", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.setTitleColor(.brand, for: .normal)
        }
        headerVStackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.spacing = 8
        }
        startToEndLabel.do {
            $0.textColor = .systemGray3
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textAlignment = .center
        }

        // 두번째
        totalSummaryStackView.do {
            $0.axis = .horizontal
            $0.spacing = 10
            $0.distribution = .fillEqually
        }

        // 세번째
        dividerView.do {
            $0.backgroundColor = .systemGray5
        }

        // 네번째
        workoutDetailTitleLabel.do {
            $0.text = "운동 상세"
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 20, weight: .semibold)
        }
    }

    func setViewHierarchy() {
        headerHStackView.addArrangedSubviews(saveButton, routineNameLabel, confirmButton)
        headerVStackView.addArrangedSubviews(headerHStackView, startToEndLabel)

        contentView.addSubviews(
            headerVStackView,
            totalSummaryStackView,
            dividerView,
            workoutDetailTitleLabel
        )
    }

    func setConstraints() {
        headerVStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.horizontalEdges.equalToSuperview()
        }

        totalSummaryStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(headerVStackView.snp.bottom).offset(20)
        }

        dividerView.snp.makeConstraints {
            $0.top.equalTo(totalSummaryStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }

        workoutDetailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - makeTotalVStackView
    /// 전체적인 Summary를 보여주는 스택뷰를 만드는 메서드 (스택뷰 재사용을 위함)
    func makeTotalVStackView(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel().then {
            $0.text = title
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .center
        }

        let valueLabel = UILabel().then {
            $0.text = value
            $0.textColor = .brand
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .center
        }

        return UIStackView(arrangedSubviews: [titleLabel, valueLabel]).then {
            $0.axis = .vertical
            $0.spacing = 8
            $0.alignment = .fill
        }
    }
}
