//
//  PrivacyWebViewController.swift
//  HowManySet
//
//  Created by GO on 6/30/25.
//

import UIKit
import WebKit

final class PrivacyWebViewController: UIViewController {
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadPrivacyHTML()
    }

    private func setupWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
    }

    private func loadPrivacyHTML() {
        if let url = Bundle.main.url(forResource: "privacy", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
}
