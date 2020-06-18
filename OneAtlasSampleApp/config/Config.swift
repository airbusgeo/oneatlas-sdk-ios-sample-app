//
//  Config.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 27/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit

import OneAtlas

class Config: NSObject {
    
    static let appColor = UIColor(hexString: AirbusPrimaryPalette.blue.rawValue)
    
    static let defaultPagingTableCount:UInt = 20
    static let livingLibraryWorkspaceID = OneAtlas.shared.livingLibraryWorkspaceID
    
    // UI stuff
    static let defaultCornerRadius = CGFloat(10)
    static let animDurationFast = 0.3
    static let animDurationSlow = 0.7
    
    
    // Map stuff
    static let cameraAnimDuration = animDurationSlow
    static let defaultSpanDegrees = 0.05
    static let mapShowsMultiStreams = false
    
    
    // Feature filters
    static let filterMaxCloud = 30
    static let filterMaxAngle = 40
    static let filterResolutions = [nil, 0.5, 1.5]

    
    // Localization helper
    class func loc(_ str:String) -> String {
        return NSLocalizedString(str, comment: "")
    }
}
