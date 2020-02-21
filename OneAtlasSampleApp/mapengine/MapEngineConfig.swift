//
//  MapEngineConfig.swift
//  MapEngineManager
//
//  Created by Airbus DS on 24/09/2019.
//

import UIKit
import CoreLocation


public class MapEngineConfig: NSObject {
    
    public static let animDurationFast = Double(0.3)
    public static let animDurationSlow = Double(0.7)
    public static let cameraAnimDuration = animDurationSlow
    
    public static let defaultSpanDegrees = Double(0.05)
}


fileprivate let LAST_LAT = "LAST_LAT"
fileprivate let LAST_LON = "LAST_LON"
fileprivate let LAST_ZOOM = "LAST_ZOOM"

public class MapEngineCache: NSObject {
    
    
    private class func set(_ val:Any, forKey key:String) {
        UserDefaults.standard.set(val, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    public static var lastLatitude:CLLocationDegrees {
        set {
            set(newValue, forKey: LAST_LAT)
        }
        get {
            return UserDefaults.standard.double(forKey: LAST_LAT)
        }
    }
    public static var lastLongitude:CLLocationDegrees {
        set {
            set(newValue, forKey: LAST_LON)
        }
        get {
            return UserDefaults.standard.double(forKey: LAST_LON)
        }
    }
    public static var lastZoom:CLLocationDegrees {
        set {
            set(newValue, forKey: LAST_ZOOM)
        }
        get {
            return UserDefaults.standard.double(forKey: LAST_ZOOM)
        }
    }
}
