import UIKit

protocol NicknameInputCoordinatorProtocol: AnyObject {
    func completeNicknameInput()
}

final class NicknameInputCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var childCoordinators: [Coordinator] = []
    private let container: DIContainer

    var finishFlow: (() -> Void)?

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let authUseCase = AuthUseCase(repository: AuthRepositoryImpl(firebaseAuthService: FirebaseAuthService()))
        let reactor = NicknameInputReactor(authUseCase: authUseCase, coordinator: self)
        let vc = NicknameInputViewController(reactor: reactor, coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
    }
    
    func childDidFinish(_ child: Coordinator) {
        childCoordinators.removeAll {
            ObjectIdentifier($0) == ObjectIdentifier(child)
        }
    }
}

extension NicknameInputCoordinator: NicknameInputCoordinatorProtocol {
    func completeNicknameInput() {
        finishFlow?()
    }
}
