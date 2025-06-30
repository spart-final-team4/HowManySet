import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import ReactorKit
import FSCalendar

final class CalendarViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag = DisposeBag()

    let calendarView = CalendarView()
    private weak var coordinator: CalendarCoordinatorProtocol? 

    // 기록이 있는 날짜를 담아놓을 배열 생성
    private var recordedDates: [Date] = []

    // RxDataSource 사용을 위한 Model 생성
    typealias RecordSection = SectionModel<String, WorkoutRecord>

    let dataSource = RxTableViewSectionedReloadDataSource<RecordSection>(
        configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecordCell.identifier, for: indexPath) as? RecordCell else {
                return UITableViewCell()
            }
            cell.configure(with: item)
            return cell
        }
    )

    // MARK: - Life Cycle
    override func loadView() {
        view = calendarView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 캘린더 날짜 선택 해제
        if let selectedDate = calendarView.publicCalendar.selectedDate {
            calendarView.publicCalendar.deselect(selectedDate)
        }

        // Reactor 상태도 초기화
        reactor?.action.onNext(.clearSelection)

        // 선택된 날짜 기준 fetch
        reactor?.action.onNext(.viewWillAppear)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setRegisters()
        setButtonTargets()
    }

    // MARK: - Init
    init(reactor: CalendarViewReactor, coordinator: CalendarCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil) // super.init을 먼저 오게하면 reactor를 따로 선언하지 않아도 된다. ReactorKit.View 안에 reactor가 있다.
        self.reactor = reactor
        self.coordinator = coordinator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reactor Binding
    func bind(reactor: CalendarViewReactor) {
        // records를 tableView에 바인딩
        reactor.state
            .map { state in
                state.selectedRecords.map { SectionModel(model: "", items: [$0]) }  // 섹션당 1개 셀
            }
            .bind(to: calendarView.publicRecordTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        reactor.state
            .map(\.allRecords) // Reactor의 [WorkoutRecord]
            .map { records in
                records.map { $0.date } // [Date]
            }
            .distinctUntilChanged() // 동일한 날짜 배열이면 업데이트 방지
            .bind(with: self) { owner, dates in
                owner.recordedDates = dates
                owner.calendarView.publicCalendar.reloadData() // 점 갱신
            }
            .disposed(by: disposeBag)

        // tableView.delegate 바인딩
        calendarView.publicRecordTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        // NotificationCenter 이벤트 수신 바인딩
        NotificationCenter.default.rx.notification(.didDismissRecordDetail)
            .bind(with: self) { owner, _ in
                let selectedDate = owner.reactor?.currentState.selectedDate ?? Date()
                owner.reactor?.action.onNext(.selectDate(selectedDate))
            }
            .disposed(by: disposeBag)

        // 화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .bind { [weak self] _ in
                guard let self else { return }
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        }
    }

// MARK: - Delegate & DataSource & Register
private extension CalendarViewController {
    func setDelegates() {
        calendarView.publicCalendar.delegate = self
        calendarView.publicCalendar.dataSource = self
    }

    func setRegisters() {
        calendarView.publicRecordTableView.register(RecordCell.self, forCellReuseIdentifier: RecordCell.identifier)
    }
}

// MARK: - Calendar buttons addTarget
private extension CalendarViewController {
    /// 버튼이 눌렸을 때 동작하는 메서드
    func setButtonTargets() {
        calendarView.publicPreviousMonthButton.addTarget(
            self,
            action: #selector(previousMonthButtonTapped),
            for: .touchUpInside
        )

        calendarView.publicNextMonthButton.addTarget(
            self,
            action: #selector(nextMonthButtonTapped),
            for: .touchUpInside
        )
    }

    /// 캘린더의 현재 페이지로 이동하는 메서드
    func moveCurrentPage(by value: Int) {
        let currentPage = calendarView.publicCalendar.currentPage

        var dateComponents = DateComponents()
        dateComponents.month = value

        if let newPage = Calendar.current.date(byAdding: dateComponents, to: currentPage) {
            calendarView.publicCalendar.setCurrentPage(newPage, animated: true)
        }
    }

    /// 현재 페이지에서 한달 전이 현재 페이지가 되는 메서드
    @objc func previousMonthButtonTapped() {
        moveCurrentPage(by: -1)
    }

    /// 현재 페이지에서 한달 후가 현재 페이지가 되는 메서드
    @objc func nextMonthButtonTapped() {
        moveCurrentPage(by: 1)
    }
}

// MARK: - UITableViewDelegate
extension CalendarViewController: UITableViewDelegate {
    /// TableView Cell의 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }

    /// TableView Cell이 선택되었을 때 실행하는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀 클릭 시 배경색 남는 것을 방지하기 위한 선택 해지
        calendarView.publicRecordTableView.deselectRow(at: indexPath, animated: true)
        
        // 해당 record 가져오기
        guard let record = reactor?.currentState.selectedRecords[indexPath.section] else { return }

        coordinator?.presentRecordDetailView(record: record)
    }

    /// trailing -> leading 방향으로 스와이프하는 메서드
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            self?.reactor?.action.onNext(.deleteItem(indexPath)) // Reactor로 이벤트 전달
                    completion(true)
                }

        deleteAction.backgroundColor = .error
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    /// tableView의 섹션 안에 있는 footerView를 설정하는 메서드
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear
        return footer
    }

    /// tableView의 섹션 안에 있는 footerView의 높이를 정하는 메서드
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        16 // 원하는 spacing 값
    }
}

// MARK: - FSCalendarDelegate
extension CalendarViewController: FSCalendarDelegate {
    /// 캘린더에서 선택된 날짜를 전달하는 메서드
    ///
    /// RxCocoa는 기본 UIKit 컴포넌트만(tableView.rx.items, button.rx.tap) 제공하기 때문에 delegate + Reactor.action 직접 전달 방식으로 구현함
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // Reactor.Action으로 selectDate 전달
        reactor?.action.onNext(.selectDate(date))
    }
}

// MARK: - FSCalendarDataSource
extension CalendarViewController: FSCalendarDataSource {
    /// 캘린더에서 이벤트가 발생한 날짜에 이벤트 점(event dot)을 표시해주는 메서드
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let calendar = Calendar.current
        
        return recordedDates.contains {
            calendar.isDate($0, inSameDayAs: date)
        } ? 1 : 0
    }
}
