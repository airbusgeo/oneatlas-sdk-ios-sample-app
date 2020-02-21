//
//  UserManager.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 20/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import OneAtlas


// =============================================================================
// MARK: - UserManager
// =============================================================================
class UserManager: NSObject {
    
    static var isFreemium = false
    static var workspaceID:String = ""
    static var balance:UInt = 0
    static var balanceUnit = "€"
    static var activeDataSubscription:OADataSubscription?
    static var freemiumAOIs:[OAUserAOI] = []
    
    
    class func refreshCurrentUser(completion: @escaping (_ user:OAUser?, _ subscriptions:[OASubscription]?, _ error:Error?) -> Void) {
        OneAtlas.sharedInstance()?.dataService.getMeWith({ (user:OAUser?, error:OAError?) in
            if let user = user {
                workspaceID = user.contract.workspaceID
                balance = user.contract.balance
                
                // grab my active subscriptions
                let page = OAPagination.makePage(0, itemsPerPage: 100)
                let filter = OASubscriptionFilter.init()
                filter.setSubscriptionStatus(ESubscriptionStatusActive)
                OneAtlas.sharedInstance()?.dataService.getSubscriptionsWith(page, filters: filter, block: { (subs:[OASubscription]?, page:OAPagination?, error:OAError?) in
                    
                    if let subs = subs {
                        for sub in subs {
                            if sub.isData, let sub = sub as? OADataSubscription {
                                
                                // am i a freemium user ?
                                // freemium accounts have allowed AOIs, which are held by the subscription
                                if sub.isFreemium {
                                    isFreemium = true
                                    if let polygons = sub.geometry as? OAMultiPolygon {
                                        // convert multi-polygon to AOI array
                                        freemiumAOIs = OAUserAOI.buildAOIsFromMultiPolygon(polygons,
                                                                                           nameFormat: Config.loc("myworkspace_freemium_area"))
                                    }
                                }
                                
                                activeDataSubscription = sub
                            }
                        }
                    }
                    completion(user, subs, error)
                })
            }
            else {
                completion(nil, nil, error)
            }
        })
    }
}
