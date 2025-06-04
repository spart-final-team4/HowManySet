import UIKit

final class CalendarViewController: UIViewController {
    private let calendarView = CalendarView()

    override func loadView() {
        view = calendarView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
