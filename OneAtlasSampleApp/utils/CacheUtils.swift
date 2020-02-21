//
//  CacheUtils.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 26/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import CoreLocation
import OneAtlas

fileprivate let FIREBASE_MESSAGING_ID = "FIREBASE_MESSAGING_ID"


fileprivate let MAP_DID_REQUEST_LOCATION = "MAP_DID_REQUEST_LOCATION"
fileprivate let MAP_DID_DECLINE_HELP = "MAP_DID_DECLINE_HELP"

class CacheUtils: NSObject {

    
    private class func set(_ val:Any, forKey key:String) {
        UserDefaults.standard.set(val, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    // firebase
    static var firebaseMessagingID:String {
        set {
            set(newValue, forKey: FIREBASE_MESSAGING_ID)
        }
        get {
            return UserDefaults.standard.string(forKey: FIREBASE_MESSAGING_ID) ?? ""
        }
    }
    
    
    // map
    static var mapDidRequestLocation:Bool {
        set {
            set(newValue, forKey: MAP_DID_REQUEST_LOCATION)
        }
        get {
            return UserDefaults.standard.bool(forKey: MAP_DID_REQUEST_LOCATION)
        }
    }
    
    
    static var mapDidDeclineHelp:Bool {
        set {
            set(newValue, forKey: MAP_DID_DECLINE_HELP)
        }
        get {
            return UserDefaults.standard.bool(forKey: MAP_DID_DECLINE_HELP)
        }
    }
}
