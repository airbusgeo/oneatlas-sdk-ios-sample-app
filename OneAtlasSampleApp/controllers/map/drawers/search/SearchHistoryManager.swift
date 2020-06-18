//
//  SearchHistoryManager.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 19/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//
import UIKit
import MapboxGeocoder

// TODO: get rid of MapboxGeocoder dependency
class SearchHistoryManager: NSObject {

    private let SHM_KEY = "SearchHistoryManager"
    private let SHM_REGION_KEY = "SearchHistoryManagerRegions" // mapbox doesnt encode regions yet
    private let MAX_PLACEMARKS = 20
    
    static let shared = SearchHistoryManager()
    
    func addSearchPlacemark(_ placemark:GeocodedPlacemark) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(placemark)
            var history = UserDefaults.standard.array(forKey: SHM_KEY) as? [Data] ?? []
            
            // do not add if present
            if history.firstIndex(of: data) == nil {
                history.insert(data, at: 0)
                if history.count > MAX_PLACEMARKS {
                    // TODO: purge region
                    history.removeLast()
                }
                UserDefaults.standard.setValue(history, forKey: SHM_KEY)
                UserDefaults.standard.synchronize()
            }
        }
        catch {
            
        }
    }
    
    
    private func addRegion(_ region:CLRegion, _ identifier:String) {
        var regiondic = UserDefaults.standard.dictionary(forKey: SHM_REGION_KEY) as? [String:String] ?? [:]
        regiondic[identifier] = region.description
        UserDefaults.standard.setValue(regiondic, forKey: SHM_REGION_KEY)
        UserDefaults.standard.synchronize()
    }
    
    
    func getHistory() -> [GeocodedPlacemark] {
        var ret:[GeocodedPlacemark] = []

        do {
            let decoder = JSONDecoder()
            let placemarks = UserDefaults.standard.array(forKey: SHM_KEY) as? [Data] ?? []
            for encode in placemarks {
                let pl = try decoder.decode(GeocodedPlacemark.self, from: encode)
                
                ret.append(pl)
            }
        }
        catch {
            
        }
        return ret
    }
    
    
    private func decodeRegion(_ region:String) -> CLRegion? {
        var ret:CLRegion?
        let bounds = region.components(separatedBy: ",")
        if bounds.count == 4,
            let swlat = Double(bounds[0]), let swlon = Double(bounds[1]),
            let nelat = Double(bounds[2]), let nelon = Double(bounds[3]) {
            let sw = CLLocationCoordinate2DMake(swlat, swlon)
            let ne = CLLocationCoordinate2DMake(nelat, nelon)
            ret = RectangularRegion(southWest: sw, northEast: ne)
        }
        
        return ret
    }
    
    
    func clearHistory() {
        UserDefaults.standard.setValue([], forKey: SHM_KEY)
        UserDefaults.standard.synchronize()
    }
}
