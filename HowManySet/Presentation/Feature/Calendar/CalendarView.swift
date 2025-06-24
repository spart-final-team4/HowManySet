import UIKit
import SnapKit
import Then
import FSCalendar

final class CalendarView: UIView {
    private let titleLabel = UILabel()
    private let calendarContainerView = UIView()
    private let calendar = FSCalendar()
    private let recordTableView = UITableView()
    private let previousMonthButton = UIButton()
    private let nextMonthButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Computed Property
    var publicCalendar: FSCalendar { calendar }
    var publicRecordTableView: UITableView { recordTableView }
    var publicPreviousMonthButton: UIButton { previousMonthButton }
    var publicNextMonthButton: UIButton { nextMonthButton }
}

// MARK: - Calendar UI 관련 extension
private extension CalendarView {
    func setupUI() {
        self.backgroundColor = .background
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        titleLabel.do {
            $0.text = "기록"
            $0.font = .systemFont(ofSize: 36, weight: .regular)
            $0.textColor = .white
        }

        calendarContainerView.do {
            $0.backgroundColor = .cardContentBG // 달력의 배경 색상 /* 추후 색상 변경 예정‼️ */
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }

        calendar.do {
            $0.scrollEnabled = true // 스크롤 가능
            $0.scrollDirection = .horizontal // 수평 방향 스크롤
            $0.locale = Locale(identifier: "ko_KR") // 달력 형식 한국어 설정
            $0.placeholderType = .none // 현재 달만 표시

            // 달력 헤더
            $0.appearance.headerDateFormat = "yyyy.MM" // 달력 헤더 날짜 형식
            $0.appearance.headerTitleColor = .textSecondary // 달력 헤더 텍스트 색상
            $0.appearance.headerTitleFont = .systemFont(ofSize: 16, weight: .regular) // 달력 헤더 텍스트 폰트
            $0.appearance.headerMinimumDissolvedAlpha = 0.0 // 달력 헤더 전 달 & 다음 달 글씨 투명도
            $0.appearance.headerTitleOffset = CGPoint(x: 0, y: -3) // 캘린더 헤더 위치 조정

            // 달력 요일
            $0.appearance.weekdayTextColor = .textTertiary // 달력 요일 텍스트 색상 /* 추후 색상 변경 예정‼️ */
            $0.appearance.weekdayFont = .systemFont(ofSize: 16, weight: .regular) // 달력 요일 텍스트 폰트

            // 달력 일반 날짜
            $0.appearance.titleDefaultColor = .textSecondary // 달력 일반 날짜 텍스트 색상
            $0.appearance.titleFont = .systemFont(ofSize: 16, weight: .regular) // 달력 일반 날짜 텍스트 폰트
            $0.appearance.titleTodayColor = .brand // 오늘 날짜 텍스트의 색상
            $0.appearance.todayColor = .clear // 오늘 날짜의 배경 색상
            $0.appearance.selectionColor = .brand // 선택된 날짜의 배경 색상
            $0.appearance.titleSelectionColor = .black // 선택된 날짜 텍스트 색상
            $0.appearance.eventDefaultColor = .success // 이벤트 점의 기본 색상
            $0.appearance.eventSelectionColor = .clear // 선택된 날짜의 이벤트 점 색상
        }

        recordTableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.showsVerticalScrollIndicator = false
        }

        previousMonthButton.do {
            $0.setImage(UIImage(named: "calendarArrowLeft"), for: .normal)
            $0.tintColor = .textSecondary
        }

        nextMonthButton.do {
            $0.setImage(UIImage(named: "calendarArrowRight"), for: .normal)
            $0.tintColor = .textSecondary
        }
    }

    func setViewHierarchy() {
        [
            titleLabel,
            calendarContainerView,
            previousMonthButton,
            nextMonthButton,
            recordTableView
        ].forEach { addSubviews($0) }

        calendarContainerView.addSubview(calendar)
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }

        calendarContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            $0.height.equalToSuperview().multipliedBy(0.37)
        }

        calendar.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
        }

        recordTableView.snp.makeConstraints {
            $0.top.equalTo(calendarContainerView.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        previousMonthButton.snp.makeConstraints {
            $0.leading.equalTo(calendar.snp.leading).offset(8)
            $0.centerY.equalTo(calendar.calendarHeaderView.snp.centerY)
            $0.width.height.equalTo(24)
        }

        nextMonthButton.snp.makeConstraints {
            $0.trailing.equalTo(calendar.snp.trailing).offset(-8)
            $0.centerY.equalTo(calendar.calendarHeaderView.snp.centerY)
            $0.width.height.equalTo(24)
        }
    }
}
