//
//  AirbusFonts.swift
//  AirbusUI
//
//  Created by Airbus DS on 30/09/2019.
//

import UIKit

private enum AirbusFontSize: CGFloat {
    case tiny = 12
    case small = 14
    case regular = 17
    case big = 20
    case huge = 32
    case megaChonk = 48
}


public enum AirbusFont {

    case megaChonk
    case huge
    case big
    case regular
    case small
    case tiny
    
    case megaChonkBold
    case hugeBold
    case bigBold
    case regularBold
    case smallBold
    case tinyBold
}


public extension AirbusFont {
    
    @available(iOS 8.2, *)
    var value: UIFont {
        var instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.regular.rawValue)
        
        switch self {
        case .megaChonk:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.megaChonk.rawValue)
        case .huge:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.huge.rawValue)
        case .big:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.big.rawValue)
        case .regular:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.regular.rawValue)
        case .small:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.small.rawValue)
        case .tiny:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.tiny.rawValue)
            
        case .megaChonkBold:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.megaChonk.rawValue, weight: .semibold)
        case .hugeBold:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.huge.rawValue, weight: .semibold)
        case .bigBold:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.big.rawValue, weight: .semibold)
        case .regularBold:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.regular.rawValue, weight: .semibold)
        case .smallBold:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.small.rawValue, weight: .semibold)
        case .tinyBold:
            instanceFont = UIFont.systemFont(ofSize: AirbusFontSize.tiny.rawValue, weight: .semibold)
        }
        return instanceFont
    }
}

