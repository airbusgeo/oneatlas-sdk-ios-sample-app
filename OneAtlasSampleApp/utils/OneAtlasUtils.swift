//
//  OneAtlasUtils.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 16/09/2019.
//  Copyright © 2019 52inc. All rights reserved.
//

import UIKit
import OneAtlas


extension Subscription {
    
    var isVisible: Bool {
        return !(self is OneAtlasSubscription)
    }
    
    var typeIcon: UIImage {
        var ret = UIImage()
        switch type(of: self) {
        case is PremiumDataSubscription.Type, is FreemiumDataSubscription.Type:
            ret = UIImage(named: "baseline_image_search_black_48pt")!
        case is EarthMonitorSubscription.Type:
            ret = UIImage(named: "icons8-earth_planet_filled")!
        case is OceanFinderSubscription.Type:
            ret = UIImage(named: "icons8-sail_boat")!
        case is AnalyticsToolboxSubscription.Type, is ChangeDetectionSubscription.Type:
            ret = UIImage(named: "baseline_compare_black_36pt")!
        case is VerdeSubscription.Type:
            ret = UIImage(named: "icons8-leaf")!
        default:
            break
        }
        return ret
    }
    
    
    var kindString: String {
        var ret = Config.loc("subscription_kind_unknown")
        switch type(of: self) {
        case is PremiumDataSubscription.Type, is FreemiumDataSubscription.Type:
            ret = Config.loc("subscription_kind_living_library")
        case is EarthMonitorSubscription.Type:
            ret = Config.loc("subscription_kind_earth_monitor")
        case is OceanFinderSubscription.Type:
            ret = Config.loc("subscription_kind_ocean_finder")
        case is AnalyticsToolboxSubscription.Type:
            ret = Config.loc("subscription_kind_analytics_toolbox")
        case is ChangeDetectionSubscription.Type:
            ret = Config.loc("subscription_kind_change_detection")
        case is VerdeSubscription.Type:
            ret = Config.loc("subscription_kind_verde")
        default:
            break
        }
        return ret
    }
    
    
    var statusString: String {
        return Subscription.statusString(status: status)
    }
    
    
    private class func statusString(status: ESubscriptionStatus) -> String {
        var ret = Config.loc("subscription_status_unknown")
        switch status {
        case .active:
            ret = Config.loc("subscription_status_active");
        case .pending:
            ret = Config.loc("subscription_status_pending");
        case .revoked:
            ret = Config.loc("subscription_status_revoked");
        case .suspended:
            ret = Config.loc("subscription_status_suspended");
        default:
            break;
        }
        return ret
    }
    
    
    var daysRemaining: Int? {
        if let ended = endedAt {
            let components = Calendar.current.dateComponents([.day],
                                                             from: Date(),
                                                             to: ended)
            return components.day!
        }
        return nil
    }
    
    
    class func amountString(_ amount:Double) -> String {
        var ret = ""
        if let ds = UserManager.activeDataSubscription {
            ret = /*ds.isTiles ? "\(Int(amount))" : */MiscUtils.megabyteString(fromKilobytes: Int(amount))
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


//extension ProductPrice {
//    var amountString: String {
//        return getAmountString(amount: Double(amount), amountUnit: amountUnit)
//    }
//}


extension DataSubscription {
    var unit:String {
        return /*isTiles ? Config.loc("unit_tiles") : */ Config.loc("unit_mb")
    }
}


extension Order {
    
    var amountString: String {
        return getAmountString(amount: amount, amountUnit: amountUnit)
    }

    
    var kindString:String {
        return Order.kindString()
    }
    
    
    class func kindString() -> String {
        var ret = Config.loc("order_details_unknown")
        switch type(of: self) {
        case is ProductOrder.Type:
            ret = Config.loc("order_details_image")
        case is AnalyticsToolboxOrder.Type:
            ret = Config.loc("order_details_analytics_toolbox");
        // TODO: compile
            /*
        case .changeDetection:
            ret = Config.loc("order_details_change_detection");
        case .earthMonitor:
            ret = Config.loc("order_details_earth_monitor");
        case .oceanFinder:
            ret = Config.loc("order_details_ocean_finder");
        case .verde:
            ret = Config.loc("order_details_verde");
             */
        default:
            break
        }
        return ret
    }
    
    
    var statusColor: UIColor {
        return Order.statusColor(status: status)
    }
    
    
    class func statusColor(status: EOrderStatus) -> UIColor {
        var color = Color.textLight.value
        switch status {
        case .delivered:
            color = Color.green.value
        case .error:
            color = Color.red.value
        default:
            break
        }
        return color
    }
    
    
    var statusString: String {
        return Order.statusString(status: status)
    }
    

    class func statusString(status: EOrderStatus) -> String {
        var ret = Config.loc("orders_status_unknown")
        switch status {
        case .ordered:
            ret = Config.loc("orders_status_pending");
        case .pending:
            ret = Config.loc("orders_status_pending");
        case .delivered:
            ret = Config.loc("orders_status_delivered");
        case .error:
            ret = Config.loc("orders_status_error");
        default:
            break;
        }
        return ret
    }
}
