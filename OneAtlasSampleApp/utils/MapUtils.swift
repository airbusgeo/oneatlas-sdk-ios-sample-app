//
//  MapUtils.swift
//  MapEngineManager
//
//  Created by Airbus DS on 11/10/2019.
//

import UIKit
import CoreLocation
import OneAtlas


extension Polygon {
    static func from(_ coords: [CLLocationCoordinate2D]) -> Polygon {
        var points: [Point] = []
        for coord in coords {
            points.append(Point.init(latitude: coord.latitude, longitude: coord.longitude))
        }
        return Polygon(from: points)
    }
}


extension CLLocationCoordinate2D {
    static func from(point: Point) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
    }
    
    static func from(points: [Point]) -> [CLLocationCoordinate2D] {
        var temp: [CLLocationCoordinate2D] = []
        for point in points {
            temp.append(CLLocationCoordinate2D.from(point: point))
        }
        return temp
    }
}


public class MapUtils: NSObject {
    
    public class func deg2rad(_ number: Double) -> Double {
        return number * Double.pi / 180.0
    }
    
    public class func getAreaM2(sw:CLLocationCoordinate2D,
                         ne:CLLocationCoordinate2D) -> Double {
        
        let a = fabs(Double.pi / 180.0)
        let b = pow(6378137.0, 2.0)
        let c = fabs(sin(deg2rad(sw.latitude)) - sin(deg2rad(ne.latitude)))
        let d = fabs(sw.longitude - ne.longitude)
        return a * b * c * d
    }
}
