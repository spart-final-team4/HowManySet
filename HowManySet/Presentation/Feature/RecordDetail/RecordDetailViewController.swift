//
//  RecordDetailViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/4/25.
//

import UIKit
import SnapKit

final class RecordDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let reactor: RecordDetailViewReactor
    
    // MARK: - UI Components
    
    
    // MARK: - Initializer
    init(reactor: RecordDetailViewReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: - UI Methods
private extension RecordDetailViewController {
    
}

