//
//  OneAtlasUtils.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 16/09/2019.
//  Copyright © 2019 52inc. All rights reserved.
//

import UIKit

import OneAtlas


extension OASubscription {
    
    var isData: Bool {
        return subscriptionKind == ESubscriptionKindDataFreemium || subscriptionKind == ESubscriptionKindDataPremium
    }
    
    var isVisible: Bool {
        return subscriptionKind != ESubscriptionKindOneAtlas
    }
    
    var typeIcon: UIImage {
        var ret = UIImage()
        switch subscriptionKind {
        case ESubscriptionKindDataPremium, ESubscriptionKindDataFreemium:
            ret = UIImage(named: "baseline_image_search_black_48pt")!
        case ESubscriptionKindEarthMonitor:
            ret = UIImage(named: "icons8-earth_planet_filled")!
        case ESubscriptionKindOceanFinder:
            ret = UIImage(named: "icons8-sail_boat")!
        case ESubscriptionKindAnalyticsToolbox, ESubscriptionKindChangeDetection:
            ret = UIImage(named: "baseline_compare_black_36pt")!
        case ESubscriptionKindVerde:
            ret = UIImage(named: "icons8-leaf")!
//        case ESubscriptionKindOneAtlas:
        default:
            break
        }
        return ret
    }
    
    
    var kindString: String {
        var ret = Config.loc("subscription_kind_unknown")
        switch subscriptionKind {
        case ESubscriptionKindDataPremium, ESubscriptionKindDataFreemium:
            ret = Config.loc("subscription_kind_living_library")
        case ESubscriptionKindEarthMonitor:
            ret = Config.loc("subscription_kind_earth_monitor")
        case ESubscriptionKindOceanFinder:
            ret = Config.loc("subscription_kind_ocean_finder")
        case ESubscriptionKindAnalyticsToolbox:
            ret = Config.loc("subscription_kind_analytics_toolbox")
        case ESubscriptionKindChangeDetection:
            ret = Config.loc("subscription_kind_change_detection")
        case ESubscriptionKindVerde:
            ret = Config.loc("subscription_kind_verde")
        //        case ESubscriptionKindOneAtlas:
        default:
            break
        }
        return ret
    }
    
    
    var statusString: String {
        return OASubscription.statusString(status: status)
    }
    
    
    private class func statusString(status:ESubscriptionStatus) -> String {
        var ret = Config.loc("subscription_status_unknown")
        switch status {
        case ESubscriptionStatusActive:
            ret = Config.loc("subscription_status_active");
        case ESubscriptionStatusPending:
            ret = Config.loc("subscription_status_pending");
        case ESubscriptionStatusRevoked:
            ret = Config.loc("subscription_status_revoked");
        case ESubscriptionStatusSuspended:
            ret = Config.loc("subscription_status_suspended");
        default:
            break;
        }
        return ret
    }
    
    
    var daysRemaining: Int {
        let components = Calendar.current.dateComponents([.day], from: Date.init(), to: endedAt)
        return components.day!
    }
    
    
    class func amountString(_ amount:Double) -> String {
        var ret = ""
        if let ds = UserManager.activeDataSubscription {
            ret = ds.isTiles ? "\(Int(amount))" : MiscUtils.megabyteString(fromKilobytes: Int(amount))
            ret = ret + " " + ds.unit
        }
        return ret
    }
}


private func getAmountString(amount:Double,
                             amountUnit:String) -> String {
    var ret = String(format: "%.02f %@", amount, amountUnit)
    
    if amountUnit.lowercased() == "kb" {
        // kB => MB
        ret = String(format: "%@ %@", MiscUtils.megabyteString(fromKilobytes: Int(amount)), Config.loc("unit_mb"))
    }
    else if amountUnit.lowercased() == "credits" ||
        amountUnit.lowercased() == "eur" {
        // credits/EUR => €
        ret = String(format: "%.02f %@", amount, Config.loc("unit_euro"))
    }
    return ret
}


extension OAProductPrice {
    var amountString: String {
        return getAmountString(amount: Double(amount), amountUnit: amountUnit)
    }
}


extension OADataSubscription {
    var isFreemium: Bool {
        return self is OADataFreemiumSubscription || self is OADataFreemiumTilesSubscription
    }
    
    var isTiles: Bool {
        return self is OADataPremiumTilesSubscription || self is OADataFreemiumTilesSubscription
    }

    var unit:String {
        return isTiles ? Config.loc("unit_tiles") : Config.loc("unit_mb")
    }
}


extension OAOrder {
    
    var amountString: String {
        return getAmountString(amount: amount, amountUnit: amountUnit)
    }

    
    var kindString:String {
        return OAOrder.kindString(kind: kind)
    }
    
    
    class func kindString(kind:EOrderKind) -> String {
        var ret = Config.loc("order_details_unknown")
        switch kind {
        case EOrderKindProduct:
            ret = Config.loc("order_details_image")
        case EOrderKindChangeDetection:
            ret = Config.loc("order_details_change_detection");
        case EOrderKindAnalyticsToolbox:
            ret = Config.loc("order_details_analytics_toolbox");
        case EOrderKindEarthMonitor:
            ret = Config.loc("order_details_earth_monitor");
        case EOrderKindOceanFinder:
            ret = Config.loc("order_details_ocean_finder");
        case EOrderKindVerde:
            ret = Config.loc("order_details_verde");
        default:
            break
        }
        return ret
    }
    
    
    var statusColor: UIColor {
        return OAOrder.statusColor(status: status)
    }
    
    
    class func statusColor(status:EOrderStatus) -> UIColor {
        var color = AirbusColor.textLight.value
        switch status {
        case EOrderStatusDelivered:
            color = AirbusColor.green.value
        case EOrderStatusError:
            color = AirbusColor.red.value
        default:
            break
        }
        return color
    }
    
    
    var statusString: String {
        return OAOrder.statusString(status: status)
    }
    

    class func statusString(status:EOrderStatus) -> String {
        var ret = Config.loc("orders_status_unknown")
        switch status {
        case EOrderStatusOrdered:
            ret = Config.loc("orders_status_pending");
        case EOrderStatusPending:
            ret = Config.loc("orders_status_pending");
        case EOrderStatusDelivered:
            ret = Config.loc("orders_status_delivered");
        case EOrderStatusError:
            ret = Config.loc("orders_status_error");
        default:
            break;
        }
        return ret
    }
}


extension OAPolygon {
    var southWest: CLLocationCoordinate2D {
        var ret: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        if let bbox = boundingBox(), bbox.count == 2 {
            ret = bbox[0].coordinate
        }
        return ret
    }
    
    
    var northEast: CLLocationCoordinate2D {
        var ret: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        if let bbox = boundingBox(), bbox.count == 2 {
            ret = bbox[1].coordinate
        }
        return ret
    }
}
