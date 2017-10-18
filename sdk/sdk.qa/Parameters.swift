//
//  Parameters.swift
//  sdk
//
//  Created by Can Soykarafakili on 05.09.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

import Foundation
import Pubnative

enum LayoutSize: Int {
    case Small = 0
    case Medium = 1
    case Large = 2
}

class Parameters
{
    static var appToken : String!
    static var placement : String!
    static var targetingModel = PNAdTargetingModel()
    static var layoutSize : LayoutSize!
}
