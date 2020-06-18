//
//  UserAOI.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 18/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import OneAtlas


class UserAOI: Polygon {

    var name: String = ""
    // var coordinates: [[Point]] = []
    
    class func buildAOIsFromMultiPolygon(_ multip: MultiPolygon,
                                         nameFormat:String) -> [UserAOI] {
        
        var idx = 0
        var temp: [UserAOI] = []
        for p in multip.polygons {
            idx += 1
            let aoi = UserAOI(from: p.coordinates[0])
            aoi.name = String(format: nameFormat, idx)
            temp.append(aoi)
        }
        return temp
    }
}
