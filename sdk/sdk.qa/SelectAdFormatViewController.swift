//
//  SelectAdFormatViewController.swift
//  sdk
//
//  Created by Can Soykarafakili on 04.09.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

import UIKit

class SelectAdFormatViewController: UIViewController
{

    @IBOutlet weak var appTokenTextField: UITextField!
    @IBOutlet weak var placementTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.appTokenTextField.text = Parameters.appToken
        self.placementTextField.text = Parameters.placement
    }
    
    @IBAction func layoutAdTouchUpInside(_ sender: UIButton)
    {
        Parameters.layoutSize = LayoutSize(rawValue:(sender as UIButton).tag)!
    }
    
}
