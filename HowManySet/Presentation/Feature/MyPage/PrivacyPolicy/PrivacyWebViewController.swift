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

    private func currentLanguageCode() -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode
    }
    
    private func localizedPrivacyFile() -> String {
        switch currentLanguageCode() {
        case "ko":
            return "PrivacyPolicy_korean"
        case "ja":
            return "PrivacyPolicy_japanese"
        default:
            return "PrivacyPolicy_english(california)"
        }
    }
    
    private func loadPrivacyHTML() {
        let fileName = localizedPrivacyFile()
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        } else {
            print("❗️Privacy Policy HTML file not found for: \(fileName)")
        }
    }
}
