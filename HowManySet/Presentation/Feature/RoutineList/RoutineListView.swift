import UIKit
import SnapKit
import Then

final class RoutineListView: UIView {
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let addNewRoutineButton = UIButton()
    private let routineTableView = UITableView()
    // FooterView 구성
    private let footerView = UIView()
    
    private var caller: ViewCaller

    // MARK: - Init
    init(frame: CGRect, caller: ViewCaller) {
        self.caller = caller
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
        setupFooterView()
    }

    func setAppearance() {
        titleLabel.do {
            $0.text = String(localized: "루틴 리스트")
            $0.font = .pretendard(size: 36, weight: .medium)
            $0.textColor = .white
        }

        routineTableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.showsVerticalScrollIndicator = false
        }

        addNewRoutineButton.do {
            $0.backgroundColor = .green6
            $0.setTitle(String(localized: "새 루틴 구성"), for: .normal)
            $0.titleLabel?.font = .pretendard(size: 18, weight: .regular)
            $0.setTitleColor(.background, for: .normal)
            $0.layer.cornerRadius = 12
            clipsToBounds = true
        }

        footerView.do {
            $0.backgroundColor = .clear
        }
    }

    func setViewHierarchy() {
        footerView.addSubview(addNewRoutineButton)

        [
            titleLabel,
            routineTableView
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }

        routineTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        addNewRoutineButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        }
    }

    // MARK: - FooterView Setting
    /// FooterView를 setup하는 메서드
    func setupFooterView() {
        // FooterView 높이 고정
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: 96)
        let fittingSize = footerView.systemLayoutSizeFitting(targetSize)
        footerView.frame.size = fittingSize

        // 테이블 뷰에 적용
        routineTableView.tableFooterView = footerView
    }
}
