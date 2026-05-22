//
//  MembershipViewController.swift
//  HowManySet
//
//  Created by MJ on 12/2/25.
//

import UIKit
import ReactorKit
import SwiftUI
import RxSwift

final class MembershipViewHostingController: UIHostingController<MembershipView>, ReactorKit.View {
    
    var disposeBag = DisposeBag()
    
    typealias Reactor = MembershipViewReactor
    
    init(reactor: MembershipViewReactor,
         rootView: MembershipView) {
        super.init(rootView: rootView)
        self.reactor = reactor
        self.rootView = rootView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectEvents()
    }
    
    private func connectEvents() {
        rootView.dismiss = { [weak self] in
            self?.reactor?.action.onNext(.dismiss)
        }
        rootView.signUpWithKakao = { [weak self] in
            self?.reactor?.action.onNext(.signUpWithKakao)
        }
        rootView.signUpWithGoogle = { [weak self] in
            self?.reactor?.action.onNext(.signUpWithGoogle)
        }
    }
    
    func bind(reactor: MembershipViewReactor) {
        reactor.state
            .map{ $0.dismiss }
            .filter{ $0 == true }
            .observe(on: MainScheduler.instance)
            .bind{ [weak self] _ in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
