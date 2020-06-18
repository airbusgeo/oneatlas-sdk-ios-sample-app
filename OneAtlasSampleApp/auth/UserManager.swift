//
//  UserManager.swift
//  OneAtlasData
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
    static var balance: Int = 0
    static var balanceUnit = "€"
    static var activeDataSubscription: DataSubscription?
    static var freemiumAOIs:[UserAOI] = []
    
    
    class func refreshCurrentUser(completion: @escaping (_ user: User?, _ subscriptions:[Subscription]?, _ error: Error?) -> Void) {
        OneAtlas.shared.dataService?.getMe({ (user: User?, error: Error?) in
            if let user = user, let contract = user.contract {
                workspaceID = contract.workspaceID
                balance = contract.balance
                
                // grab my active subscriptions
                let page = Pagination(page: 0, itemsPerPage: 100)
                let filter = SubscriptionFilter()
                filter.status = .active
                
                //filter.setSubscriptionStatus(ESubscriptionStatusActive)
                OneAtlas.shared.dataService?.get(type: Subscription.self, pagination: page, filter: filter, block: { (subs:[Subscription]?, page:Pagination?, error:Error?) in
                    
                    if let subs = subs {
                        for sub in subs {
                            if let sub = sub as? DataSubscription {
                                
                                // am i a freemium user ?
                                // freemium accounts have allowed AOIs, which are held by the subscription
                                if sub is FreemiumDataSubscription {
                                    isFreemium = true
                                    if let polygons = sub.geometry as? MultiPolygon {
                                        // convert multi-polygon to AOI array
                                        freemiumAOIs = UserAOI.buildAOIsFromMultiPolygon(polygons,
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
