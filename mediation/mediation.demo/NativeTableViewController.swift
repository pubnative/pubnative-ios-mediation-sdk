//
//  NativeTableViewController.swift
//  mediation
//
//  Created by David Martin on 6/30/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation

class NativeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var message: UILabel!
    // MARK: - UIViewController -
    @IBOutlet weak var tableView: UITableView!
    
    var data : [CellRequestModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.message.layer.masksToBounds = true
        self.message.layer.cornerRadius = 5
        for placement in Settings.placements {
            
            data.append(CellRequestModel(placement:placement))
        }
    }
    
    // MARK: - UITableViewController -
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var result = 0
        if(data.count>0) {
            result = 1
        }
        return result
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "NativeTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! NativeTableViewCell
        cell.data = data[indexPath.row]
        cell.controller = self
        return cell
    }
    
    // MARK: - NativeTableViewController -
    
    func showMessage(message:String!) {
        
        self.message.text = message
        self.message.alpha = 0
        self.message.hidden = false
        
        UIView.animateWithDuration(0.25, animations: { self.message.alpha = 0.75 }, completion:{ (completed) in
            let delayTime = 3
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delayTime) * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                UIView.animateWithDuration(0.25, animations: { self.message.alpha = 0 }, completion:{ (value: Bool) in self.message.hidden = true })
            })})
    }
}