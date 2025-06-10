import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import FSCalendar

final class CalendarViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag = DisposeBag()

    private let calendarView = CalendarView()
    private weak var coordinator: CalendarCoordinatorProtocol?
    // ReactorKit.View는 내부적으로 reactor 프로퍼티에 didSet이 필요하기 때문에 Reactor? {get set}을 요구함
    var reactor: CalendarViewReactor?

    // MARK: - Life Cycle
    override func loadView() {
        view = calendarView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setRegisters()

        if let reactor = reactor {
            bind(reactor: reactor)
        }
    }

    // MARK: - Init
    init(reactor: CalendarViewReactor, coordinator: CalendarCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
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

// MARK: - UITableViewDelegate
extension CalendarViewController: UITableViewDelegate {
    /// TableView Cell의 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
