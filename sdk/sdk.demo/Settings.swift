//
//  Settings.swift
//  sdk
//
//  Created by David Martin on 6/30/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation

class Settings
{
    static var appToken : String = "e3886645aabbf0d5c06f841a3e6d77fcc8f9de4469d538ab8a96cb507d0f2660"
//    static var appToken : String = "2c6fdfd723dd4a6ba52e8e6878138145"
    static var placements : [String] = ["facebook_only",
                                        "pubnative_only",
                                        "yahoo_only",
                                        "waterfall",
                                        "imp_day_cap_10",
                                        "imp_hour_cap_10",
                                        "pacing_cap_hour_1",
                                        "pacing_cap_min_1",
                                        "disabled"]
    
    static func addPlacement(_ placementName:String!)
    {
        if(!placementName.isEmpty && !placements.contains(placementName)){
            placements.append(placementName)
        }
    }
    
    static func removePlacement(_ placementName:String!)
    {
        if(!placementName.isEmpty && placements.contains(placementName)){
            placements.remove(at: placements.index(of: placementName)!)
        }
    }
}
