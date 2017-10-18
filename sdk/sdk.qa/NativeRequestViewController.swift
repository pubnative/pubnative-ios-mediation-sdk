//
//  NativeRequestViewController.swift
//  sdk
//
//  Created by Can Soykarafakili on 05.09.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

import UIKit
import Pubnative

class NativeRequestViewController: UIViewController
{
    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var fetchAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    @IBOutlet weak var startAdTrackingButton: UIButton!
    @IBOutlet weak var adDetailView: UIView!
    @IBOutlet weak var impressionIndicatorImageView: UIImageView!
    @IBOutlet weak var clickIndicatorImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nativeAdContainer: UIView!
    @IBOutlet weak var nativeAdIcon: UIImageView!
    @IBOutlet weak var nativeAdTitle: UILabel!
    @IBOutlet weak var nativeAdRating: PNStarRatingView!
    @IBOutlet weak var nativeAdBanner: UIView!
    @IBOutlet weak var nativeAdDescription: UILabel!
    @IBOutlet weak var nativeAdCallToAction: UIButton!
    
    var nativeRequest : NativeAdRequestModel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func loadNativeAdTouchUpInside(_ sender: UIButton)
    {
        self.loadAdButton.setBackgroundColor(color: UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.00), forState: .normal)
        self.startAdTrackingButton.setBackgroundColor(color: UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.00), forState: .normal)
        self.impressionIndicatorImageView.image = UIImage(named: "fail")
        self.clickIndicatorImageView.image = UIImage(named: "fail")
        self.adDetailView.isHidden = true
        self.nativeAdContainer.isHidden = true
        self.showAdButton.isEnabled = false
        self.fetchAdButton.isEnabled = false
        self.activityIndicator.startAnimating()
        
        if(nativeRequest == nil) {
            nativeRequest = NativeAdRequestModel (placement: Parameters.placement)
        }
        nativeRequest?.request.start(withAppToken: Parameters.appToken,
                                     placementName: nativeRequest?.placement,
                                     delegate: self)
        
    }
    
    func renderAd()
    {
        let renderer = PNAdModelRenderer()
        renderer.iconView = self.nativeAdIcon
        renderer.titleView = self.nativeAdTitle
        renderer.starRatingView = self.nativeAdRating
        renderer.bannerView = self.nativeAdBanner
        renderer.descriptionView = self.nativeAdDescription
        renderer.callToActionView = self.nativeAdCallToAction
        
        nativeRequest?.model?.renderAd(renderer)
    }
    
    @IBAction func showNativeAdTouchUpInside(_ sender: UIButton)
    {
        renderAd()
        nativeAdContainer.isHidden = false
    }
    
    @IBAction func setCacheResourcesTouchUpInside(_ sender: UIButton)
    {
        sender.isSelected = !sender.isSelected
        nativeRequest?.request.cacheResources = sender.isSelected
        if sender.isSelected {
            self.fetchAdButton.setBackgroundColor(color: UIColor(red:0.33, green:0.59, blue:0.23, alpha:1.00), forState: .normal)
        } else {
            self.fetchAdButton.setBackgroundColor(color: UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.00), forState: .normal)
        }
    }
    
    @IBAction func startTrackingAdTouchUpInside(_ sender: UIButton)
    {
        self.startAdTrackingButton.setBackgroundColor(color: UIColor(red:0.33, green:0.59, blue:0.23, alpha:1.00), forState: .normal)
        nativeRequest?.model?.delegate = self
        nativeRequest?.model?.startTrackingView(self.nativeAdContainer, with: self)
    }
    
    @IBAction func stopTrackingAdTouchUpInside(_ sender: UIButton)
    {
        self.startAdTrackingButton.setBackgroundColor(color: UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.00), forState: .normal)
        nativeRequest?.model?.stopTracking()
    }
}

extension NativeRequestViewController : PNRequestDelegate
{
    func pubnativeRequestDidStart(_ request: PNRequest!)
    {
        
    }
    
    func pubnativeRequest(_ request: PNRequest!, didLoad ad: PNAdModel!)
    {
        self.loadAdButton.setBackgroundColor(color: UIColor(red:0.33, green:0.59, blue:0.23, alpha:1.00), forState: .normal)
        nativeRequest?.model = ad
        self.adDetailView.isHidden = false
        self.showAdButton.isEnabled = true
        self.fetchAdButton.isEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    func pubnativeRequest(_ request: PNRequest!, didFail error: Error!)
    {
        self.loadAdButton.setBackgroundColor(color: UIColor(red:0.76, green:0.21, blue:0.18, alpha:1.00), forState: .normal)
        self.adDetailView.isHidden = true
        self.showAdButton.isEnabled = false
        self.fetchAdButton.isEnabled = false
        self.activityIndicator.stopAnimating()
        
        let alert = UIAlertView (title: "PubNative", message: "Error: \(error.localizedDescription)", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}

extension NativeRequestViewController : PNAdModelDelegate
{
    func pubantiveAdDidConfirmImpression(_ ad: PNAdModel!)
    {
        self.impressionIndicatorImageView.image = UIImage(named: "success")
    }
    
    func pubnativeAdDidClick(_ ad: PNAdModel!)
    {
        self.clickIndicatorImageView.image = UIImage(named: "success")
    }
}
