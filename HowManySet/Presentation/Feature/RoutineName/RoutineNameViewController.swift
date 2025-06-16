import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class RoutineNameViewController: UIViewController {

    let routineNameView = RoutineNameView()
    private let reactor: RoutineNameReactor

    init(reactor: RoutineNameReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func loadView() {
        view = routineNameView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
