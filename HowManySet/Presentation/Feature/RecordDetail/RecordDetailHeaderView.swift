import UIKit
import SnapKit
import Then

final class RecordDetailHeaderView: UIView {
    // MARK: - Properties
    private let routineNameLabel = UILabel()
    private let saveButton = UIButton()
    private let confirmButton = UIButton()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - configure
    func configure(with record: WorkoutRecord) {
        // 루틴명
        routineNameLabel.text = record.workoutRoutine.name
    }
}

// MARK: - Computed Properties
extension RecordDetailHeaderView {
    var publicConfirmButton: UIButton { confirmButton }
    var publicSaveButton: UIButton { saveButton }
}

// MARK: - 저장버튼 활성화 상태 정하는 메서드
extension RecordDetailHeaderView {
    func updateSaveButtonEnabled(_ isEnabled: Bool) {
        publicSaveButton.isEnabled = isEnabled
        publicSaveButton.setTitleColor(isEnabled ? .white : .systemGray, for: .normal)
    }
}

// MARK: - RecordDetailHeaderView UI 관련 extension
private extension RecordDetailHeaderView {
    func setupUI() {
        backgroundColor = .clear
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
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
    }

    func setViewHierarchy() {
        addSubviews(saveButton, routineNameLabel, confirmButton)
    }

    func setConstraints() {
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.centerY.equalToSuperview()
        }

        confirmButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.centerY.equalToSuperview()
        }

        routineNameLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
