//
//  CellRequestModel.swift
//  mediation
//
//  Created by David Martin on 7/1/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation

class CellRequestModel {
    
    var request : PubnativeNetworkRequest
    var model : PubnativeAdModel?
    var placement : String
    
    init(placement:String) {
        
        self.request = PubnativeNetworkRequest()
        self.placement = placement
        self.model = nil;
    }
}