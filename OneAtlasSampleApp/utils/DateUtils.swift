//
//  DateUtils.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 28/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import DateToolsSwift
import OneAtlas


extension DateUtils {
   
    class func readableDateUTC(date:Date) -> String {
        let df = DateFormatter.init()
        df.dateStyle = .medium
        df.timeStyle = .none
        df.timeZone = TimeZone(identifier: "UTC")
        df.locale = Locale(identifier: "en_US")
        return df.string(from: date)
    }
    
    class func readableTimeUTC(date:Date) -> String {
        let df = DateFormatter.init()
        df.dateStyle = .none
        df.timeStyle = .short
        df.timeZone = TimeZone(identifier: "UTC")
        df.locale = Locale(identifier: "en_US")
        return df.string(from: date)
    }
    
 
    class func niceTime(date:Date, utc:Bool) -> String {
        let df = DateFormatter.init()
        df.dateStyle = .none
        df.timeStyle = .short
        if utc {
            df.timeZone = TimeZone(identifier: "UTC")
        }
        df.dateFormat = "HH:mm:ss"
        return (df.string(from: date) + (utc == true ? " UTC" : ""))
    }
 
    class func niceDate(date:Date, daysAgo:Int, utc:Bool) -> String {
    
        var ret:String?
        if daysAgo > -1 && Date.init().days(from: date) < daysAgo {
            ret = date.timeAgoSinceNow
        }
        else {
            let df = DateFormatter.init()
            df.dateStyle = .medium
            df.timeStyle = .none
            if utc {
                df.timeZone = TimeZone(identifier: "UTC")
            }
            df.locale = Locale(identifier: "en_US")
            ret = df.string(from: date)

        }
        return ret!
    }
}
