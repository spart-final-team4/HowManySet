import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import FSCalendar

final class CalendarViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag = DisposeBag()

    let calendarView = CalendarView()
    private var coordinator: CalendarCoordinatorProtocol? // 이유는 모르겠지만 weak를 쓰면 인스턴스가 메모리에서 해제됨. 따라서 일단 strong으로 구현하자

    // MARK: - Life Cycle
    override func loadView() {
        view = calendarView
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
            .map(\.records)
            .bind(to: calendarView.publicRecordTableView.rx.items(
                cellIdentifier: RecordCell.identifier,
                cellType: RecordCell.self
            )) { _, record, cell in
                cell.configure(with: record)
            }
            .disposed(by: disposeBag)

        // tableView.delegate 설정
        calendarView.publicRecordTableView.rx.setDelegate(self)
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
        UIScreen.main.bounds.height * 0.15
    }

    /// TableView Cell이 선택되었을 때 실행하는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀 클릭 시 배경색 남는 것을 방지하기 위한 선택 해지
        calendarView.publicRecordTableView.deselectRow(at: indexPath, animated: true)

        // 해당 record 가져오기
        guard let record = reactor?.currentState.records[indexPath.row] else { return }

        coordinator?.presentRecordDetailView(record: record)
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
        return WorkoutRecord.mockData.contains(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        }) ? 1 : 0
    }
}
