//
//  CalendarViewController.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

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
