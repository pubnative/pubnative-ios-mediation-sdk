//
//  CellRequestModel.swift
//  sdk
//
//  Created by David Martin on 7/1/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

import Foundation
import Pubnative

class CellRequestModel
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
