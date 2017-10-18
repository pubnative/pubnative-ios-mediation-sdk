//
//  TrackingParameterCell.swift
//  sdk
//
//  Created by Can Soykarafakili on 04.09.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

import UIKit

class TargetingParameterCell: UITableViewCell
{
    @IBOutlet weak var targetingParameterKey: UILabel!
    @IBOutlet weak var targetingParameterValue: UILabel!
    
    func configureCell(targetingParameter: Dictionary<String,String>)
    {
        self.targetingParameterKey.text = targetingParameter.keys.first
        self.targetingParameterValue.text = targetingParameter.values.first
    }
}
