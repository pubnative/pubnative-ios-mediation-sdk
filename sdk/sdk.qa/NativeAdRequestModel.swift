//
//  NativeAdRequestModel.swift
//  sdk
//
//  Created by Can Soykarafakili on 11.09.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

import Foundation
import Pubnative

class NativeAdRequestModel
{
    var request : PNRequest
    var model : PNAdModel?
    var placement : String
    
    init(placement:String)
    {
        self.request = PNRequest()
        self.placement = placement
        self.model = nil;
    }
}
