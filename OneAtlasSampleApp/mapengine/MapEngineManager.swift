//
//  MapEngineManager.swift
//  OneAtlasData
//
//  Created by Airbus DS on 23/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import CoreLocation
import Mapbox
import MapKit
import OneAtlas


// =========================================================================
// MARK: - OneAtlas layer types
// =========================================================================
public enum EMapLayer: String, CaseIterable {
    
    case street = "street"
    case basemap = "onelive"
    case worldDEM = "worlddem"
    
    func isOneAtlas() -> Bool {
        return self != .street
    }
}


// =============================================================================
// MARK: - AOIShape
// =============================================================================
public enum EAOIType:String, CaseIterable {
    case unknown
    case search
    case stream
    case user
}


// =============================================================================
// MARK: - RectangularRegion
// =============================================================================
public struct MapRectangularRegion {
    var sw:CLLocationCoordinate2D
    var ne:CLLocationCoordinate2D
    var name:String
    
    public init(sw:CLLocationCoordinate2D,
                ne:CLLocationCoordinate2D,
                name:String = "") {
        self.sw = sw
        self.ne = ne
        self.name = name
    }
}


// =============================================================================
// MARK: - MapEngine
// =============================================================================
public protocol MapEngineManagerDelegate {
    // map engine
    func mapEngineDidFinishLoading(map:UIView, error:Error?)
    
    // user interactions
    func userDidTapMap(atCoordinate coord:CLLocationCoordinate2D)
    func userDidLongpressMap(atCoordinate coord:CLLocationCoordinate2D)
    func userWillMoveMap()
    func userIsMovingMap()
    func userDidMoveMap()
    
    // camera control
    func cameraDidFly(toCoordinate coord:CLLocationCoordinate2D)
    
    // stream control
    func addedStreamFromFeature(_ feature:OAProductFeature, workspaceKind:Int?, error: Error?)
}


public protocol MapEngineContract {
    func setPOIAnnotation(atCoordinate coord:CLLocationCoordinate2D, title:String?, subtitle:String?)
    func removePOIAnnotation()
    func addAOIShape(polygon:OAPolygon, type:EAOIType, title:String?, color:UIColor)
    func addAOIShapeForCurrentViewport(edgeInsets:UIEdgeInsets?, type:EAOIType, title:String?, color:UIColor)
    func removeAOIShape(type:EAOIType)
    
    func addStreamFromProductFeature(_ feature:OAProductFeature, aoiColor: UIColor, workspaceKind:Int?)
    func removeStream()
    
    func flyCameraToCoordinate(coord:CLLocationCoordinate2D, span:CLLocationDegrees, duration:TimeInterval)
    func flyCameraToRegion(region:MapRectangularRegion, edgeInsets:UIEdgeInsets?, duration:TimeInterval)
    func adjustCameraToEdgeInsets(_ edgeInsets:UIEdgeInsets, span:CLLocationDegrees, duration:TimeInterval)
    func restoreCamera(duration:TimeInterval)
    func polygonForCurrentViewport(edgeInsets:UIEdgeInsets?) -> OAPolygon
    func areaForCurrentViewport(edgeInsets:UIEdgeInsets?) -> Double
    
    func showLayer(_ layer:EMapLayer)
}


public let DEFAULT_MAP_PADDING:CGFloat = 8.0

public enum EMapEngine: Int {
    case mapbox = 0
}


public class MapEngineManager: NSObject {

    
    public class func managerForMapView(_ mapView:UIView,
                                        delegate:MapEngineManagerDelegate) -> MapEngineContract? {
        var ret:MapEngineContract?
        if let map = mapView as? MGLMapView {
            ret = MapboxEngineManager(mapView: map, delegate: delegate)
        }
        return ret
    }
}
