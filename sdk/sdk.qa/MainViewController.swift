//
//  MainViewController.swift
//  sdk
//
//  Created by Can Soykarafakili on 04.09.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

import UIKit
import Pubnative

class MainViewController: UIViewController {
    
    @IBOutlet weak var appTokenTextField: UITextField!
    @IBOutlet weak var configurationView: UIView!
    @IBOutlet weak var placementButton: UIButton!
    @IBOutlet weak var targetingParameterKeyTextField: UITextField!
    @IBOutlet weak var targetingParameterValueTextField: UITextField!
    @IBOutlet weak var targetingParametersTableView: UITableView!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var selectionPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var placements = [String : PNPlacementModel]()
    var targetingParameterDictionary = [String:String]()
    var targetingParameters = [Dictionary<String, String>]()
    var isPlacement = true
    var isPlacementSelected = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.appTokenTextField.text = Settings.appToken
    }
    
    @IBAction func submitTouchUpInside(_ sender: UIButton)
    {
        self.placementButton.setTitle("Choose Placement", for: .normal)
        self.configurationView.isHidden = true
        self.activityIndicator.startAnimating()
        PNConfigManager.config(withAppToken: self.appTokenTextField.text,
                               extras: nil,
                               delegate: self)
    }
    
    @IBAction func pubnativeInitTouchUpInside(_ sender: UIButton)
    {
        Pubnative.initWithAppToken(self.appTokenTextField.text)
        sender.isSelected = true
        sender.setBackgroundColor(color: UIColor(red:0.33, green:0.59, blue:0.23, alpha:1.00), forState: .selected)
    }
    
    @IBAction func testingModeTouchUpInside(_ sender: UIButton)
    {
        sender.isSelected = !sender.isSelected
        Pubnative.setTestMode(sender.isSelected)
        
        if sender.isSelected {
            sender.setBackgroundColor(color: UIColor(red:0.33, green:0.59, blue:0.23, alpha:1.00), forState: .selected)
        } else {
            sender.setBackgroundColor(color: UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.00), forState: .normal)
        }
    }
    
    @IBAction func coppaModeTouchUpInside(_ sender: UIButton)
    {
        sender.isSelected = !sender.isSelected
        Pubnative.setCoppa(sender.isSelected)
        
        if sender.isSelected {
            sender.setBackgroundColor(color: UIColor(red:0.33, green:0.59, blue:0.23, alpha:1.00), forState: .selected)
        } else {
            sender.setBackgroundColor(color: UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.00), forState: .normal)
        }
    }
    
    @IBAction func addTrackingParametersTouchUpInside(_ sender: UIButton)
    {
        self.targetingParameters.removeAll()
        self.targetingParameterDictionary[self.targetingParameterKeyTextField.text!] = self.targetingParameterValueTextField.text!
    
        for targetingKey in self.targetingParameterDictionary.keys {
            let targetingElement = [targetingKey : self.targetingParameterDictionary[targetingKey]] as! [String : String]
            self.targetingParameters.append(targetingElement)
        }
        
        self.targetingParametersTableView.reloadData()
        self.view.endEditing(true)
        self.targetingParameterKeyTextField.text = ""
        self.targetingParameterValueTextField.text = ""
    }
    
    @IBAction func choosePlacementTouchUpInside(_ sender: UIButton)
    {
        self.isPlacement = true
        self.selectionPickerView.reloadAllComponents()
        self.selectionView.isHidden = false
    }
    
    @IBAction func chooseTargetingParameterKeyTouchUpInside(_ sender: UIButton)
    {
        self.isPlacement = false
        self.selectionPickerView.reloadAllComponents()
        self.selectionView.isHidden = false
    }
    
    @IBAction func chooseSelectionTouchUpInside(_ sender: UIButton)
    {
        if isPlacement {
            self.placementButton.setTitle([String](self.placements.keys)[self.selectionPickerView.selectedRow(inComponent: 0)], for: .normal)
            self.isPlacementSelected = true
        } else {
            self.targetingParameterKeyTextField.text = Settings.targetingParameters[self.selectionPickerView.selectedRow(inComponent: 0)]
        }
        self.selectionView.isHidden = true
    }

    @IBAction func nextTouchUpInside(_ sender: UIButton)
    {
        if self.isPlacementSelected {
            Parameters.appToken = self.appTokenTextField.text
            Parameters.placement = self.placementButton.titleLabel?.text
            Parameters.targetingModel = configureAdTargetingModel(targetingDictionary: self.targetingParameterDictionary)
            Pubnative.setTargeting(Parameters.targetingModel)
            
            performSegue(withIdentifier: "goToSelectFormat", sender: self)
        } else {
            let alert = UIAlertView (title: "PubNative",
                                     message: "Please choose a placement",
                                     delegate: nil,
                                     cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func configureAdTargetingModel(targetingDictionary:[String:String]) -> PNAdTargetingModel
    {
        let targetingModel = PNAdTargetingModel()

        if let age = targetingDictionary["age"] {
            targetingModel.age = NSNumber(value: Int(age)!)
        }
        
        if let education = targetingDictionary["education"] {
            targetingModel.education = education
        }
        
        if let interests = targetingDictionary["interests"] {
            targetingModel.interests = interests.components(separatedBy: ",")
        }
        
        if let gender = targetingDictionary["gender"] {
            targetingModel.gender = gender as NSString
        }
        
        if let iap = targetingDictionary["iap"] {
            targetingModel.iap = NSNumber(value: Int(iap)!)
        }
        
        if let iap_total = targetingDictionary["iap_total"] {
            targetingModel.iap_total = NSNumber(value: Int(iap_total)!)
        }

        return targetingModel
    }
}

extension MainViewController : PNConfigManagerDelegate
{
    func configDidFinish(with model: PNConfigModel!)
    {
        self.activityIndicator.stopAnimating()
        self.configurationView.isHidden = false
        self.placements = model.placements
        PNConfigManager.reset()
    }
}

extension MainViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 30
    }
}

extension MainViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.targetingParameters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell", for: indexPath) as? TargetingParameterCell {
            cell.configureCell(targetingParameter: self.targetingParameters[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let targetingElementKey = self.targetingParameters[indexPath.row].keys.first
            self.targetingParameterDictionary.removeValue(forKey: targetingElementKey!)
            self.targetingParameters.remove(at: indexPath.row)
            self.targetingParametersTableView.reloadData()
        }
    }
}

extension MainViewController : UIPickerViewDelegate
{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if self.isPlacement {
            let placementKeys = [String](self.placements.keys)
            return placementKeys[row]
        } else {
            return Settings.targetingParameters[row]
        }
    }
}

extension MainViewController : UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if self.isPlacement {
            return self.placements.count
        } else {
            return Settings.targetingParameters.count
        }
    }
}

extension MainViewController : UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.endEditing(true)
        return true
    }
}
