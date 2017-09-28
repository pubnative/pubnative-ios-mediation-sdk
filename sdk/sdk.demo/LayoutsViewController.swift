//
//  LayoutsViewController.swift
//  sdk
//
//  Created by Can Soykarafakili on 12.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

import UIKit
import Pubnative

enum LayoutSize: Int {
    case Small = 0
    case Medium = 1
    case Large = 2
}

class LayoutsViewController : UIViewController
{
    @IBOutlet weak var placementTextField: UITextField!
    @IBOutlet weak var adView: UIView!
    
    var layoutSize : LayoutSize!
    var placementName : NSString!
    var layoutSelected : Bool = false
    var apiLayout = PNAPILayout()
    var adViewController : PNAPILayoutViewController!
    var largeLayout : PNLargeLayout!
    var activityIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        placementTextField.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        if ((adViewController) != nil) {
            adViewController.stopTracking()
        }
    }
    
    @IBAction func layoutButtonPressed(_ sender: UIButton)
    {
        resetLayoutButtons()
        sender.isSelected = true
        sender.backgroundColor = UIColor.purple
        layoutSize = LayoutSize(rawValue:(sender as UIButton).tag)!
        layoutSelected = true
    }
    
    @IBAction func requestLayout(_ sender: UIButton)
    {
        placementTextField.resignFirstResponder()
        self.addActivityIndicator()
        activityIndicator.startAnimating()

        if (layoutSelected && (placementName != nil) && (placementName.length > 0)) {
            switch layoutSize.rawValue {
            case 0:
                let layout = PNSmallLayout()
                layout.loadDelegate = self;
                layout.load(withAppToken: Settings.appToken, placement: "iOS_asset_group_\(placementName!)")
                break
            case 1:
                let layout = PNMediumLayout()
                layout.loadDelegate = self;
                layout.load(withAppToken: Settings.appToken, placement: "iOS_asset_group_\(placementName!)")
                break
            case 2:
                let layout = PNLargeLayout ()
                layout.loadDelegate = self
                layout.load(withAppToken: Settings.appToken, placement: "iOS_asset_group_\(placementName!)")
                break
            default: break
            }
        } else {
            let alert = UIAlertView (title: "PubNative Demo", message: "Please select both placement name and a size in order to make a request.", delegate: nil, cancelButtonTitle: "OK")
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            alert.show()
        }
    }
    
    func addActivityIndicator ()
    {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    
    
    func resetLayoutButtons()
    {
        for views in view.subviews {
            if let button = views as? UIButton {
                if button.tag != 100 {
                    button.isSelected = false
                    button.backgroundColor = UIColor(red:0.63, green:0.63, blue:0.63, alpha:1.00)
                }
            }
        }
    }
    
    func removePreviousLayoutFrom(view: UIView)
    {
        for view in adView.subviews{
            view.removeFromSuperview()
        }
    }
    
    public func activateConstraintsFor(adView: UIView, respectTo parentView: UIView) -> Void
    {
        adView.translatesAutoresizingMaskIntoConstraints = false
        let bottomContraint = NSLayoutConstraint (item: adView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let topContraint = NSLayoutConstraint (item: adView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1.0, constant: 0)
        let leftContraint = NSLayoutConstraint (item: adView, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1.0, constant: 0)
        let rightContraint = NSLayoutConstraint (item: adView, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([topContraint, leftContraint, bottomContraint, rightContraint])
    }
    
}

extension LayoutsViewController : PNLayoutLoadDelegate
{
    func layoutDidFinishLoading(_ layout: PNLayout!)
    {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        
        switch layoutSize.rawValue {
        case 0:
            let smallLayout = layout as! PNSmallLayout
            smallLayout.trackDelegate = self
            smallLayout.startTrackingView()
            let viewController = smallLayout.viewController
            removePreviousLayoutFrom(view: adView)
            adView.addSubview((viewController?.view)!)
            break
        case 1:
            let mediumLayout = layout as! PNMediumLayout
            mediumLayout.trackDelegate = self
            mediumLayout.startTrackingView()
            let viewController = mediumLayout.viewController
            removePreviousLayoutFrom(view: adView)
            adView.addSubview((viewController?.view)!)
            break
        case 2:
            largeLayout = layout as! PNLargeLayout
            largeLayout.trackDelegate = self
            largeLayout.viewDelegate = self
            largeLayout.show()
            break
            
        default: break
        }
    }
    
    func layout(_ layout: PNLayout!, didFailLoading error: Error!)
    {
        
    }
}

extension LayoutsViewController : PNLayoutTrackDelegate
{
    func layoutTrackClick(_ layout: PNLayout!)
    {
        print("Layout track click")
    }
    
    func layoutTrackImpression(_ layout: PNLayout!)
    {
        print("Layout track impression")
    }
}

extension LayoutsViewController : PNLayoutViewDelegate
{
    func layoutDidShow(_ layout: PNLayout!)
    {
        print("Layout has been shown in the screen")
    }

    func layoutDidHide(_ layout: PNLayout!)
    {
        print("Layout has been hidden in the screen")
    }

}

extension LayoutsViewController : UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        placementTextField.becomeFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        placementName = textField.text! as NSString
    }
}
