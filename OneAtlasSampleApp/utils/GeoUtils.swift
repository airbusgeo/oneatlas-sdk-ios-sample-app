//
//  GeoUtils.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 23/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import MapboxGeocoder
import OneAtlas

class GeoUtils: NSObject {

    private static let SQUARE_METERS_STR_LIMIT = Double(1 * 100 * 1000)
    
    static let SQUARE_METERS_IN_SQUARE_KILOMETER = Double(1 * 1000 * 1000)
    
    class func areaSquareMetersToString(_ areaSquareMeters:Double) -> String {
        var area_str = String(format: "%.02f m²", areaSquareMeters)
        if areaSquareMeters > SQUARE_METERS_STR_LIMIT {
            area_str = String(format: "%.02f km²", (areaSquareMeters / SQUARE_METERS_IN_SQUARE_KILOMETER))
        }
        return area_str
    }
    
    class func areaString(polygon:OAPolygon) -> String {
        var area_str = "Invalid value"
        let area = MapUtils.getAreaM2(sw: polygon.southWest,
                                      ne: polygon.northEast)
        area_str = areaSquareMetersToString(area)
        return area_str
    }
    
    
    
    class func coordinateString(coord:CLLocationCoordinate2D) -> String {
        return String(format: "%.04f,%.04f", coord.latitude, coord.longitude)
    }
    
    
    static var accessToken:String = "" {
        didSet {
            GeoUtils._shared = Geocoder(accessToken: accessToken)
        }
    }
    
    
    private static var _shared:Geocoder?
    
    
    private class func placemarkFromCoordinate(coord:CLLocationCoordinate2D) -> GeocodedPlacemark? {
        var pl:GeocodedPlacemark?
        do {
            let json_str = "{\"id\":\"user_marker\",\"text\":\"Marker placed\",\"center\":[$lon,$lat]}"
                .replacingOccurrences(of: "$lat", with: String.init(format: "%.5f", coord.latitude))
                .replacingOccurrences(of: "$lon", with: String.init(format: "%.5f", coord.longitude))
            
            if let json = json_str.data(using: .utf8) {
                let decoder = JSONDecoder()
                pl = try decoder.decode(GeocodedPlacemark.self, from: json)
            }
        }
        catch {
            print(error)
        }
        return pl
    }
    
    
    class func performGeocoding(query:String,
                                completion: @escaping (_ placemarks:[GeocodedPlacemark]?, _ error:NSError?) -> Void) {
        // we have sufficient characters to perform search
        let options = ForwardGeocodeOptions(query: query)
        
        // To refine the search, you can set various properties on the options object.
        options.focalLocation = nil
        options.maximumResultCount = 20
        options.allowedScopes = [.country, .region, .district, .place, .locality, .pointOfInterest]
        
        GeoUtils._shared?.geocode(options) { (placemarks:[GeocodedPlacemark]?, attribution:String?, error:NSError?) in
            if let placemarks = placemarks {
                var temp = [GeocodedPlacemark]()
                var idx = 0
                for pl in placemarks {
                    if let _ = pl.location {
                        temp.append(pl)
                        print("\(idx) - \(pl.name)")
                        print("\(pl.qualifiedName ?? "")")
                        idx += 1
                    }
                }
                completion(temp, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    
    private static var _reverseCache:[String:GeocodedPlacemark] = [:]
    class func performReverseGeocoding(coord:CLLocationCoordinate2D,
                                       completion: @escaping (_ placemark:GeocodedPlacemark?, _ error:NSError?) -> Void) {
        
        let coord_str = GeoUtils.coordinateString(coord: coord)
        if let placemark = _reverseCache[coord_str] {
            // we got this coord in cache
            completion(placemark, nil)
        }
        else {
            let options = ReverseGeocodeOptions(coordinate: coord)
            options.allowedScopes = [.place]
            let task = GeoUtils._shared?.geocode(options) { (placemarks:[GeocodedPlacemark]?, attribution:String?, error:NSError?) in
                if let error = error {
                    completion(nil, error)
                }
                else {
                    var pl = placemarkFromCoordinate(coord: coord)
                    if let pls = placemarks, pls.count > 0 {
                        pl = pls[0]
                    }
                    self._reverseCache[coord_str] = pl
                    completion(pl, nil)
                }
            }
            task?.resume()
        }
    }
}
