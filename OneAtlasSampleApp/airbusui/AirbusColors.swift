//
//  AirbusColors.swift
//  Source: https://gist.github.com/sauvikatinnofied/92c25739d4ae7bb5cc45e6b75fd63fe7
//  Data: https://brand.airbus.com/brand-guidelines/digital-experience/visual-guidelines/colours.html
//
//  Created by Airbus DS on 07/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import Foundation
import UIKit

public enum AirbusPrimaryPalette: String {
    case blueUltraDark = "#00205B"
    case blueDark = "#005587"
    case blue = "#167dde"
    case blueLight = "#6399AE"
    case blueUltraLight = "#B7C9D3"
}


public enum AirbusSecondaryPalette: String {
    // sec palette line 1
    case green = "#84bd00"
    case yellowGreen = "#e1e000"
    case yellow = "#fabd00"
    case orange = "#ff7700"
    
    // sec palette line 2
    case red = "#e4002b"
    case pink = "#da1884"
    
    // sec palette line 3
    case teal = "#00aec7"
}


public enum AirbusColor {
    
    case background
    
    case airbus
    
    case textDark
    case textLight
    case textUltraLight
    case textWhite
    
    case green
    case orange
    case red
    case pink
    case teal
    
    case notifications
    case workspace
    case orders
    case subscriptions
    
    case cardTableBackground
    case cardCell
    case cardHeader
    
    case custom(hexString: String, alpha: Double)
    
    func withAlpha(_ alpha: Double) -> UIColor {
        return self.value.withAlphaComponent(CGFloat(alpha))
    }
}

public extension AirbusColor {
    
    var value: UIColor {
        var instanceColor = UIColor.clear
        
        switch self {
        case .background, .airbus:
            instanceColor = UIColor(hexString: AirbusPrimaryPalette.blueDark.rawValue)
            
        case .textDark:
            instanceColor = UIColor.darkGray
        case .textLight:
            instanceColor = UIColor.lightGray
        case .textUltraLight, .cardTableBackground:
            instanceColor = UIColor.init(white: 0.84, alpha: 1)
        case .textWhite, .cardHeader:
            instanceColor = UIColor.init(white: 1, alpha: 0.9)
        case .cardCell:
            instanceColor = UIColor.init(white: 1, alpha: 0.8)
            
        case .green, .subscriptions:
            instanceColor = UIColor(hexString: AirbusSecondaryPalette.green.rawValue)
        case .pink, .orders:
            instanceColor = UIColor(hexString: AirbusSecondaryPalette.pink.rawValue)
        case .orange, .notifications:
            instanceColor = UIColor(hexString: AirbusSecondaryPalette.orange.rawValue)
        case .red:
            instanceColor = UIColor(hexString: AirbusSecondaryPalette.red.rawValue)
        case .teal, .workspace:
            instanceColor = UIColor(hexString: AirbusSecondaryPalette.teal.rawValue)
            
        case .custom(let hexValue, let opacity):
            instanceColor = UIColor(hexString: hexValue).withAlphaComponent(CGFloat(opacity))
        }
        return instanceColor
    }
}

public extension UIColor {
    
    func rgbHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
    
    /**
     Creates an UIColor from HEX String in "#363636" format
     
     - parameter hexString: HEX String in "#363636" format
     
     - returns: UIColor from HexString
     */
    convenience init(hexString: String) {
        
        let hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner          = Scanner(string: hexString as String)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}
