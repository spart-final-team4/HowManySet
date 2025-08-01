import UIKit
import SnapKit
import Then

final class RoutineNameView: UIView {
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let routineNameTF = UITextField()
    private let nextButton = UIButton()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Computed Property
    var publicNextButton: UIButton { nextButton }
    var publicRoutineNameTF: UITextField { routineNameTF }
}

// MARK: - EditRoutineView UI 관련 extension
private extension RoutineNameView {
    func setupUI() {
        backgroundColor = .background
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        titleLabel.do {
            $0.text = String(localized: "루틴명을 입력해주세요")
            $0.font = .pretendard(size: 20, weight: .regular)
            $0.textColor = .white
        }

        routineNameTF.do {
            $0.backgroundColor = .bsInputFieldBG
            $0.placeholder = String(localized: "예) 상체 루틴, 2분할 (하체/어깨)")
            $0.minimumFontSize = 16
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.textColor = .white

            // textField 왼쪽 뷰 padding 설정
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
            $0.leftViewMode = .always

            // 키보드 관련
            $0.autocorrectionType = .no // 자동 수정 끔
            $0.spellCheckingType = .no // 맞춤법 검사 끔
            $0.smartInsertDeleteType = .no // 스마트 삽입/삭제 끔
            $0.autocapitalizationType = .none // 영문으로 시작할 때 자동 대문자 끔
        }

        nextButton.do {
            $0.setTitle(String(localized: "다음"), for: .normal)
            $0.titleLabel?.font = .pretendard(size: 18, weight: .regular)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
    }

    func setViewHierarchy() {
        [
            titleLabel,
            routineNameTF,
            nextButton
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(28)
        }

        routineNameTF.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(56)
        }

        nextButton.snp.makeConstraints {
            $0.top.equalTo(routineNameTF.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        }
    }
}
