//
//  MiscUtils.swift
//
//  Created by Airbus DS on 12/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit

class MiscUtils: NSObject {
    
    class func deg2rad(deg:Double) -> Double {
        return ((deg * .pi) / 180.0)
    }
    
    
    class func rad2deg(rad:Double) -> Double {
        return ((rad * 180.0) / .pi)
    }
    
    
    class func megabyteString(fromKilobytes kilobytes:Int) -> String {
        let nf = NumberFormatter.init()
        nf.groupingSeparator = " "
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: "en_EN")
        
        let kb = Double(kilobytes)
        var mb = kb / Double(1024)
        
        // keep only 2 decimal figures
        mb = floor(mb * 100) / 100
        return nf.string(from: NSNumber(value: mb)) ?? ""
    }
    
    
    static var isJailbrokenDevice: Bool {
#if !(TARGET_IPHONE_SIMULATOR)

        // these files might be present on JB devices
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app") ||
            FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            FileManager.default.fileExists(atPath: "/bin/bash") ||
            FileManager.default.fileExists(atPath: "/usr/sbin/sshd") ||
            FileManager.default.fileExists(atPath: "/etc/apt") ||
            FileManager.default.fileExists(atPath: "/private/var/lib/apt/") {
                return true
        }
        
        // Cydia indicates a JB device
        if let url = URL(string: "cydia://package/com.example.package"),
            UIApplication.shared.canOpenURL(url) {
            return true
        }
        
        // TODO: more cases
#endif
        return false;
    }
}


extension UIImage {
    
    public func tintedImageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
    
}

