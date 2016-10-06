//
//  NativeTableViewCell.swift
//  mediation
//
//  Created by David Martin on 6/30/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation

class NativeTableViewCell: UITableViewCell, PubnativeNetworkRequestDelegate {
    
    // MARK: Properties

    var controller : NativeTableViewController!
    weak var data : CellRequestModel? {
        didSet {
            
            adView.hidden = true
            adapter.text = ""
            
            placement.text = "Placement ID: " + (data?.placement)!
            if(data?.model != nil) {
                renderAd(data!.model)
            }
        }
    }
    
    // MARK: OUTLETS

    @IBOutlet weak var placement: UILabel!
    @IBOutlet weak var adapter: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    // Ad 
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adBanner: UIImageView!
    @IBOutlet weak var adIcon: UIImageView!
    @IBOutlet weak var adTitle: UILabel!
    @IBOutlet weak var adDescription: UILabel!
    
    // MARK: ACTIONS
    
    @IBAction func requestTouchUpInside(sender: AnyObject){
        
        adView.hidden = true
        adapter.text = ""
        loader.startAnimating()
        
        data?.request.startWithAppToken(Settings.appToken, placementName:data?.placement, delegate: self)
    }
    
    // MARK: -
    // MARK: CALLBACKS
    // MARK: -
    
    // MARK: PubnativeNetworkRequestDelegate
    
    func pubnativeRequestDidStart(request: PubnativeNetworkRequest!) {
        print("pubnativeRequestDidStart");
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest!, didFail error: NSError!) {
        print("pubnativeRequest:didFail:%@", error);
        
        controller.showMessage("Error: \(error)")
        
        self.loader.stopAnimating()
    }
    
    func pubnativeRequest(request: PubnativeNetworkRequest!, didLoad ad: PubnativeAdModel!) {
        print("pubnativeRequest:didLoad:");
        
        if(ad != nil){
            data?.model = ad
            renderAd(data?.model)
        }
    }
    func renderAd(model:PubnativeAdModel!) {
        
        self.adapter.text = NSStringFromClass(model.classForCoder)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let iconData:NSData? = NSData(contentsOfURL: NSURL(string:model.iconURL)!)!;
            let bannerData:NSData? = NSData(contentsOfURL: NSURL(string:model.bannerURL)!)!;
            
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let iconImage:UIImage = UIImage(data: iconData!)!;
                let bannerImage:UIImage = UIImage(data: bannerData!)!;
                
                self.adTitle.text = model.title;
                self.adDescription.text = model.description;
                self.adBanner.image = bannerImage;
                self.adIcon.image = iconImage;
        
                self.loader.stopAnimating()
                self.adView.hidden = false;
                model.startTrackingView(self.adView, withViewController:self.controller);
            }
        }
    }
}