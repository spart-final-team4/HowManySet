//
//  FSTestViewController.swift
//  HowManySet
//
//  Created by GO on 6/12/25.
//

import UIKit
import SnapKit
import Then

class FSTestViewController: UIViewController {

    private let firestoreTestButton = UIButton(type: .system).then {
        $0.setTitle("Firestore 테스트", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(firestoreTestButton)
        firestoreTestButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(150)
        }
        firestoreTestButton.addTarget(self, action: #selector(didTapFirestoreTest), for: .touchUpInside)
    }

    /// FirestoreService 테스트 실행
    @objc private func didTapFirestoreTest() {
        Task {
            await FirestoreService.shared.testFirestoreService()
        }
    }
}
