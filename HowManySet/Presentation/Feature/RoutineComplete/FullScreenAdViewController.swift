//
//  FullScreenAdViewController.swift
//  HowManySet
//
//  Created by 정근호 on 9/3/25.
//

import UIKit
import Then
import GoogleMobileAds

final class FullScreenAdViewController: UIViewController, FullScreenContentDelegate {
    
    private var interstitial: InterstitialAd?
    
    init(interstitial: InterstitialAd? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.interstitial = interstitial
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print("FullScreenAd ViewLoaded")
    }
    
    func loadInterstitial() async {
        do {
            interstitial = try await InterstitialAd.load(
                with: "ca-app-pub-3940256099942544/4411468910", request: Request())
            interstitial?.fullScreenContentDelegate = self
            interstitial?.present(from: self)
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("\(#function) called with error: \(error.localizedDescription)")
        // Clear the interstitial ad.
        interstitial = nil
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
        // Clear the interstitial ad.
        interstitial = nil
    }
}
