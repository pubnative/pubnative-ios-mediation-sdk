//
//  SettingsViewController.swift
//  sdk
//
//  Created by David Martin on 7/1/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation
import Pubnative

class SettingsViewController: UIViewController, UIAlertViewDelegate
{    
    @IBOutlet weak var coppaSwitch: UISwitch!
    
    @IBAction func reset(_ sender: UIButton)
    {
        PNConfigManager.reset()
        UIAlertView(title: "success", message: "config reset completed", delegate: self, cancelButtonTitle: "ok").show()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
//        coppaSwitch.isOn = PNSettings.sharedInstance().coppa
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        Pubnative.setCoppa(coppaSwitch.isOn)
    }
}
