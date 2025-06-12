import UIKit
import SnapKit
import Then

final class RoutineListView: UIView {
    private let titleLabel = UILabel()
    private let addNewRoutineButton = UIButton()
    private let routineTableView = UITableView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Computed Property
    var publicAddNewRoutineButton: UIButton { addNewRoutineButton }
    var publicRoutineTableView: UITableView { routineTableView }
}

// MARK: - RoutineList UI 관련 extension
private extension RoutineListView {
    func setupUI() {
        self.backgroundColor = .background
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        titleLabel.do {
            $0.text = "루틴 리스트"
            $0.font = .systemFont(ofSize: 36, weight: .regular)
            $0.textColor = .white
        }

        routineTableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
        }

        addNewRoutineButton.do {
            $0.backgroundColor = .disabledButton
            $0.setTitle("새 루틴 구성", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
            $0.tintColor = .white
            $0.layer.cornerRadius = 12
            clipsToBounds = true
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = 20
            $0.alignment = .fill
            $0.distribution = .fill
        }
    }

    func setViewHierarchy() {
        addSubview(stackView)

        [titleLabel, routineTableView, addNewRoutineButton].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    func setConstraints() {
        stackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            $0.bottom.lessThanOrEqualTo(safeAreaLayoutGuide).inset(20)
        }

        addNewRoutineButton.snp.makeConstraints {
            $0.height.equalTo(safeAreaLayoutGuide.snp.height).multipliedBy(0.07)
        }
    }
}
