//
//  SettingsViewController.swift
//  mediation
//
//  Created by David Martin on 7/1/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation


class SettingsViewController: UIViewController, UIAlertViewDelegate {
    
    @IBAction func reset(sender: UIButton) {
        
        PubnativeConfigManager.reset()
        UIAlertView(title: "success", message: "config reset completed", delegate: self, cancelButtonTitle: "ok").show()
    }
}