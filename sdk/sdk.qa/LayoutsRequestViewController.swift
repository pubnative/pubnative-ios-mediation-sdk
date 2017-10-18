//
//  LayoutsRequestViewController.swift
//  sdk
//
//  Created by Can Soykarafakili on 05.09.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

import UIKit
import Pubnative

class LayoutsRequestViewController: UIViewController
{
    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    @IBOutlet weak var startAdTrackingButton: UIButton!
    @IBOutlet weak var adDetailView: UIView!
    @IBOutlet weak var adContainerView: UIView!
    @IBOutlet weak var impressionIndicatorImageView: UIImageView!
    @IBOutlet weak var clickIndicatorImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var smallLayout : PNSmallLayout?
    var mediumLayout : PNMediumLayout?
    var largeLayout : PNLargeLayout?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func loadLayoutAdTouchUpInside(_ sender: UIButton)
    {
        self.loadAdButton.setBackgroundColor(color: UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.00), forState: .normal)
        self.startAdTrackingButton.setBackgroundColor(color: UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.00), forState: .normal)
        self.impressionIndicatorImageView.image = UIImage(named: "fail")
        self.clickIndicatorImageView.image = UIImage(named: "fail")
        self.adDetailView.isHidden = true
        self.showAdButton.isEnabled = false
        self.activityIndicator.startAnimating()
        
        switch Parameters.layoutSize.rawValue {
        case 0:
            loadSmall()
            break
        case 1:
            loadMedium()
            break
        case 2:
            loadLarge()
            break
        default:
            break
        }
    }
    
    func loadSmall()
    {
        if(smallLayout == nil) {
            smallLayout = PNSmallLayout()
        }
        loadLayout(layout: smallLayout)
    }
    
    func loadLayout(layout:PNLayout?)
    {
        layout?.load(withAppToken: Parameters.appToken,
                     placement: Parameters.placement,
                     delegate: self)
        layout?.trackDelegate = self
    }
    
    func loadMedium()
    {
        if(mediumLayout == nil) {
            mediumLayout = PNMediumLayout()
        }
        loadLayout(layout: mediumLayout)
    }
    
    func loadLarge()
    {
        if(largeLayout == nil) {
            largeLayout = PNLargeLayout()
            largeLayout?.viewDelegate = self
        }
        loadLayout(layout: largeLayout)
    }
    
    @IBAction func showLayoutAdTouchUpInside(_ sender: UIButton)
    {
        switch Parameters.layoutSize.rawValue {
        case 0:
            showSmall()
            break
        case 1:
            showMedium()
            break
        case 2:
            showLarge()
            break
        default:
            break
        }
    }
    
    func showSmall()
    {
        adContainerView.addSubview((smallLayout?.viewController.view)!)
    }
    
    func showMedium()
    {
        adContainerView.addSubview((mediumLayout?.viewController.view)!)
    }
    
    func showLarge()
    {
        largeLayout?.show()
    }
    
    @IBAction func startTrackingAdTouchUpInside(_ sender: UIButton)
    {
        self.startAdTrackingButton.setBackgroundColor(color: UIColor(red:0.33, green:0.59, blue:0.23, alpha:1.00), forState: .normal)
        switch Parameters.layoutSize.rawValue {
        case 0:
            smallLayout?.startTrackingView()
            break
        case 1:
            mediumLayout?.startTrackingView()
            break
        case 2:
            break
        default:
            break
        }
    }
    
    @IBAction func stopTrackingAdTouchUpInside(_ sender: UIButton)
    {
        self.startAdTrackingButton.setBackgroundColor(color: UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.00), forState: .normal)
        switch Parameters.layoutSize.rawValue {
        case 0:
            smallLayout?.stopTrackingView()
            break
        case 1:
            mediumLayout?.stopTrackingView()
            break
        case 2:
            break
        default:
            break
        }
    }
}

extension LayoutsRequestViewController : PNLayoutLoadDelegate
{
    func layoutDidFinishLoading(_ layout: PNLayout!)
    {
        self.loadAdButton.setBackgroundColor(color: UIColor(red:0.33, green:0.59, blue:0.23, alpha:1.00), forState: .normal)
        self.adDetailView.isHidden = false
        self.showAdButton.isEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    func layout(_ layout: PNLayout!, didFailLoading error: Error!)
    {
        self.loadAdButton.setBackgroundColor(color: UIColor(red:0.76, green:0.21, blue:0.18, alpha:1.00), forState: .normal)
        self.adDetailView.isHidden = true
        self.showAdButton.isEnabled = false
        self.activityIndicator.stopAnimating()
        
        let alert = UIAlertView (title: "PubNative",
                                 message: "Error: \(error.localizedDescription)",
                                 delegate: nil,
                                 cancelButtonTitle: "OK")
        alert.show()
    }
}

extension LayoutsRequestViewController : PNLayoutTrackDelegate
{
    func layoutTrackClick(_ layout: PNLayout!)
    {
        self.clickIndicatorImageView.image = UIImage(named: "success")
    }
    
    func layoutTrackImpression(_ layout: PNLayout!)
    {
        self.impressionIndicatorImageView.image = UIImage(named: "success")
    }
}

extension LayoutsRequestViewController : PNLayoutViewDelegate
{
    func layoutDidShow(_ layout: PNLayout!)
    {
        
    }
    
    func layoutDidHide(_ layout: PNLayout!)
    {
        
    }
}
