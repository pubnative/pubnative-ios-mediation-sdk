//
//  NativeTableViewController.swift
//  sdk
//
//  Created by David Martin on 6/30/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation
import Pubnative

class NativeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var message: UILabel!
    // MARK: - UIViewController -
    @IBOutlet weak var tableView: UITableView!
    
    var data : [CellRequestModel] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.message.layer.masksToBounds = true
        self.message.layer.cornerRadius = 5
        for placement in Settings.placements {
            data.append(CellRequestModel(placement:placement))
        }
    }
    
    // MARK: - UITableViewController -
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var result = 0
        if(data.count>0) {
            result = 1
        }
        return result
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "NativeTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NativeTableViewCell
        cell.data = data[indexPath.row]
        cell.controller = self
        return cell
    }
    
    // MARK: - NativeTableViewController -
    
    func showMessage(_ message:String!)
    {
        self.message.text = message
        self.message.alpha = 0
        self.message.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: { self.message.alpha = 0.75 }, completion:{ (completed) in
            let delayTime = 3
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(Double(delayTime) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                UIView.animate(withDuration: 0.25, animations: { self.message.alpha = 0 }, completion:{ (value: Bool) in self.message.isHidden = true })
            })})
    }
}
