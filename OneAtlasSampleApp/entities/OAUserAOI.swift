//
//  OAUserAOI.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 18/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import OneAtlas


class OAUserAOI: OAPolygon {

    var name:String = ""
    
    class func buildAOIsFromMultiPolygon(_ multip:OAMultiPolygon,
                                         nameFormat:String) -> [OAUserAOI] {
        
        var idx = 0
        var temp:[OAUserAOI] = []
        for p in multip.polygons {
            idx += 1
            let aoi = OAUserAOI()
            aoi.name = String(format: nameFormat, idx)
            aoi.coordinates = p.coordinates
            temp.append(aoi)
        }
        return temp
    }
}
