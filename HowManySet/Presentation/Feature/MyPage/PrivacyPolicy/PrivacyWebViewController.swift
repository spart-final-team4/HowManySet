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
    
    /// 현재 사용자의 지역 코드 리턴
    /// ex) ko-Kore_KR  ->  KR
    private func currentLocaleRegionIdentifier() -> String {
        return Locale.current.region?.identifier ?? "KR"
    }
    
    private func localizedPrivacyFile() -> String {
        let regionCode = currentLocaleRegionIdentifier()
        print(regionCode)
        switch regionCode {
        case "KR":
            return "PrivacyPolicy_Korea"
        case "JP":
            return "PrivacyPolicy_Japan"
        case "AR":
            return "PrivacyPolicy_Argentina"
        case "BO":
            return "PrivacyPolicy_Bolivia"
        case "CL":
            return "PrivacyPolicy_Chile"
        case "CO":
            return "PrivacyPolicy_Colombia"
        case "CR":
            return "PrivacyPolicy_CostaRica"
        case "CU":
            return "PrivacyPolicy_Cuba"
        case "DO":
            return "PrivacyPolicy_DominicanRepublic"
        case "EC":
            return "PrivacyPolicy_Ecuador"
        case "SV":
            return "PrivacyPolicy_ElSalvador"
        case "GT":
            return "PrivacyPolicy_Guatemala"
        case "HN":
            return "PrivacyPolicy_Honduras"
        case "MX":
            return "PrivacyPolicy_Mexico"
        case "NI":
            return "PrivacyPolicy_Nicaragua"
        case "PA":
            return "PrivacyPolicy_Panama"
        case "PY":
            return "PrivacyPolicy_Paraguay"
        case "PE":
            return "PrivacyPolicy_Peru"
        case "PR":
            return "PrivacyPolicy_PuertoRico"
        case "UY":
            return "PrivacyPolicy_Uruguay"
        case "VE":
            return "PrivacyPolicy_Venezuela"
        default:
            return "PrivacyPolicy_US(California)"
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
