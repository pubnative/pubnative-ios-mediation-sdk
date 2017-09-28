//
//  NativeTableViewCell.swift
//  sdk
//
//  Created by David Martin on 6/30/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation
import Pubnative

class NativeTableViewCell: UITableViewCell, PNRequestDelegate {
    
    // MARK: Properties
    
    var controller : NativeTableViewController!
    weak var data : CellRequestModel? {
        
        willSet {
            if (data?.model != nil) {
                data?.model?.stopTracking()
            }
            contentInfo?.removeFromSuperview()
        }
        
        didSet {
            
            adView.isHidden = true
            adapter.text = ""
            
            placement.text = "Placement ID: " + (data?.placement)!
            if(data?.model != nil) {
                renderAd()
            }
        }
    }
    
    var contentInfo : UIView? = nil
    
    // MARK: OUTLETS
    
    @IBOutlet weak var placement: UILabel!
    @IBOutlet weak var adapter: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    // Ad
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adBanner: UIView!
    @IBOutlet weak var adIcon: UIImageView!
    @IBOutlet weak var adTitle: UILabel!
    @IBOutlet weak var adDescription: UILabel!
    @IBOutlet weak var adViewContainer: UIView!
    @IBOutlet weak var adRating: PNStarRatingView!
    @IBOutlet weak var adCallToAction: UIButton!
    // MARK: ACTIONS
    
    @IBAction func requestTouchUpInside(_ sender: AnyObject){
        
        loader.startAnimating()
        adView.isHidden = true
        
        adapter.text = ""
        data?.request.start(withAppToken: Settings.appToken, placementName:data?.placement, delegate: self)
    }
    
    // MARK: private
    
    func renderAd() {
        
        adapter.text = NSStringFromClass((data?.model!.classForCoder)!)
        
        let renderer = PNAdModelRenderer()
        renderer.titleView = adTitle
        renderer.descriptionView = adDescription
        renderer.iconView = adIcon
        renderer.bannerView = adBanner
        renderer.starRatingView = adRating
        renderer.callToActionView = adCallToAction
        renderer.contentInfoView = contentInfo
        
        data?.model!.renderAd(renderer)
        data?.model!.startTrackingView(self.adView, with:self.controller)
        
        loader.stopAnimating()
        adView.isHidden = false
    }
    
    // MARK: -
    // MARK: CALLBACKS
    // MARK: -
    
    // MARK: PNRequestDelegate
    
    func pubnativeRequestDidStart(_ request: PNRequest!) {
        print("pubnativeRequestDidStart");
    }
    
    func pubnativeRequest(_ request: PNRequest!, didFail error: Error!) {
        print("pubnativeRequest:didFail:%@", error);
        
        controller.showMessage("Error: \(error)")
        
        self.loader.stopAnimating()
    }
    
    func pubnativeRequest(_ request: PNRequest!, didLoad ad: PNAdModel!) {
        print("pubnativeRequest:didLoad:");
        
        if(ad != nil){
            data?.model?.stopTracking()
            contentInfo?.removeFromSuperview()
            
            data?.model = ad
            renderAd()
        }
    }
}
