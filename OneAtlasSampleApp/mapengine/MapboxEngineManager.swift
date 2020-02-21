//
//  MapboxEngineManager.swift
//  OneAtlasData
//
//  Created by Airbus DS on 22/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import Mapbox
import OneAtlas

fileprivate let STREAM_PREFIX = "com.airbus.stream."
fileprivate let LAYER_PREFIX = "com.airbus.layer."
fileprivate let TILE_MATRIX_SET = "3857"


// =========================================================================
// MARK: - AOIShape
// =========================================================================
class AOIShape: MGLPolyline {
    var type:EAOIType = .unknown
    var color:UIColor = .red
    var polygon:OAPolygon?
}


// =========================================================================
// MARK: - POIAnnotation
// =========================================================================
class POIAnnotation: MGLPointAnnotation {
    
}


// =========================================================================
// MARK: - MapboxEngineManager
// =========================================================================
class MapboxEngineManager: NSObject, MapEngineContract {
    
    private var _mapView:MGLMapView
    private var _streamCache:[String:OATileLayer] = [:]
    private var _previousCamera:MGLMapCamera?
    private var _poiAnnotation = POIAnnotation.init()
    private var _aoiShape = AOIShape.init()
    private var _delegate:MapEngineManagerDelegate?
    
    init(mapView:MGLMapView,
         delegate:MapEngineManagerDelegate) {
        
        _mapView = mapView
        _delegate = delegate
        
        super.init()
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(onMapTapped(_:)))
        _mapView.addGestureRecognizer(tgr)
        tgr.delegate = self

        let lgr = UILongPressGestureRecognizer(target: self, action: #selector(onMapLongpressed(_:)))
        if let recognizers = mapView.gestureRecognizers {
            for recognizer in recognizers {
                if let longpress = recognizer as? UILongPressGestureRecognizer {
                    lgr.require(toFail: longpress)
                }
            }
        }
        
        _mapView.addGestureRecognizer(lgr)
        _mapView.delegate = self
    }
    
    
    // =========================================================================
    // MARK: - User Interactions
    // =========================================================================
    @objc func onMapTapped(_ sender: Any) {
        if let gesture = sender as? UITapGestureRecognizer {
            let touch = gesture.location(in: _mapView)
            let coord = _mapView.convert(touch, toCoordinateFrom: _mapView)
            _delegate?.userDidTapMap(atCoordinate:  coord)
        }
    }
    
    
    @objc func onMapLongpressed(_ sender: Any) {
        if let gesture = sender as? UILongPressGestureRecognizer {
            if gesture.state == .began {
                // get geo coords
                let touch = gesture.location(in: _mapView)
                let coord = _mapView.convert(touch, toCoordinateFrom: _mapView)
                _delegate?.userDidLongpressMap(atCoordinate: coord)
            }
        }
    }
    
    

    // =========================================================================
    // MARK: - Annotations
    // =========================================================================
    func setPOIAnnotation(atCoordinate coord:CLLocationCoordinate2D,
                          title:String? = nil,
                          subtitle:String? = nil) {
        removePOIAnnotation()
        if let title = title {
            _poiAnnotation.title = title
        }
        if let subtitle = subtitle {
            _poiAnnotation.subtitle = subtitle
        }
        _poiAnnotation.coordinate = coord
        _mapView.addAnnotation(_poiAnnotation)
    }
    
    
    func removePOIAnnotation() {
        _mapView.removeAnnotation(_poiAnnotation)
    }
    
    
    private func coordinatesForCurrentViewport(edgeInsets:UIEdgeInsets? = nil) -> [CLLocationCoordinate2D] {
        let top = (edgeInsets?.top ?? 0)
        let left = (edgeInsets?.left ?? 0)
        let bottom = (edgeInsets?.bottom ?? 0)
        let right = (edgeInsets?.right ?? 0)
        
        let rect = CGRect(x: _mapView.bounds.origin.x + left,
                          y: _mapView.bounds.origin.y + top,
                          width: _mapView.bounds.size.width - (right + left),
                          height: _mapView.bounds.size.height - (bottom + top))
        let bounds = _mapView.convert(rect, toCoordinateBoundsFrom: _mapView)
        let coords = [
            CLLocationCoordinate2DMake(bounds.ne.latitude, bounds.ne.longitude),
            CLLocationCoordinate2DMake(bounds.sw.latitude, bounds.ne.longitude),
            CLLocationCoordinate2DMake(bounds.sw.latitude, bounds.sw.longitude),
            CLLocationCoordinate2DMake(bounds.ne.latitude, bounds.sw.longitude),
            CLLocationCoordinate2DMake(bounds.ne.latitude, bounds.ne.longitude)
        ]
        return coords
    }
    
    
    func areaForCurrentViewport(edgeInsets:UIEdgeInsets?) -> Double {
        let top = (edgeInsets?.top ?? 0)
        let left = (edgeInsets?.left ?? 0)
        let bottom = (edgeInsets?.bottom ?? 0)
        let right = (edgeInsets?.right ?? 0)

        let rect = CGRect(x: _mapView.bounds.origin.x + left,
                          y: _mapView.bounds.origin.y + top,
                          width: _mapView.bounds.size.width - (right + left),
                          height: _mapView.bounds.size.height - (bottom + top))
        let bounds = _mapView.convert(rect, toCoordinateBoundsFrom: _mapView)
        return MapUtils.getAreaM2(sw: bounds.sw, ne: bounds.ne)
    }

    
    func polygonForCurrentViewport(edgeInsets:UIEdgeInsets? = nil) -> OAPolygon {
        var coords = coordinatesForCurrentViewport(edgeInsets: edgeInsets)
        return OAPolygon(fromCoordinates: UnsafeMutablePointer<CLLocationCoordinate2D>(&coords), count: 5)
    }
    
    
    func addAOIShapeForCurrentViewport(edgeInsets:UIEdgeInsets? = nil,
                                       type:EAOIType,
                                       title:String? = nil,
                                       color:UIColor) {
        // remove previous
        removeAOIShape(type: type)

        // reset map rotation else its ugly (no animation if heading is zero)
        let camera = _mapView.camera
        let duration = camera.heading == 0 ? 0 : MapEngineConfig.animDurationFast
        camera.heading = 0
        camera.pitch = 0
        _mapView.setCamera(camera,
                      withDuration: duration,
                      animationTimingFunction: CAMediaTimingFunction(name: .easeOut)) {
                        
            let coords = self.coordinatesForCurrentViewport(edgeInsets: edgeInsets)
            let aoi = AOIShape(coordinates: coords, count: 5)
            
            aoi.type = type
            aoi.title = title ?? type.rawValue
            aoi.color = color
            
            var c = coords
            aoi.polygon = OAPolygon(fromCoordinates: UnsafeMutablePointer<CLLocationCoordinate2D>(&c), count: 5)

            // add annotation
            self._mapView.addAnnotation(aoi)
        }
    }
    
    
    func addAOIShape(polygon:OAPolygon,
                     type:EAOIType,
                     title:String? = nil,
                     color:UIColor) {
        for poly:[OAPoint] in polygon.coordinates {
            var coords = [CLLocationCoordinate2D]()
            for point in poly {
                coords.append(point.coordinate)
            }
            let aoi = AOIShape(coordinates: coords, count: 5)
            aoi.polygon = polygon
            aoi.type = type
            aoi.title = title ?? type.rawValue
            aoi.color = color
            _mapView.addAnnotation(aoi)
        }
    }
    
    
    func removeAOIShape(type:EAOIType) {
        // remove previous annotation of type
        if let aoi = _mapView.annotations?.first(where: { (annotation) -> Bool in
            var ret = false
            if let aoi = annotation as? AOIShape {
                ret = (aoi.type == type)
            }
            return ret
        }) {
            _mapView.removeAnnotation(aoi)
        }
    }
    
    
    // =========================================================================
    // MARK: - Streaming
    // =========================================================================
    func addStreamFromProductFeature(_ feature: OAProductFeature,
                                     aoiColor: UIColor,
                                     workspaceKind: Int? = nil) {
        let source_id = feature.ident + "-source"
        let layer_id = STREAM_PREFIX + feature.ident
        var add_source = false
        
        if let style = _mapView.style {
            if let source = style.source(withIdentifier: source_id) {
                // source was already added, just set visible
                if let layer = style.layer(withIdentifier: layer_id) {
                    layer.isVisible = true
                    addedStreamFromProductFeatureCompletion(feature,
                                                            shapeColor: aoiColor,
                                                            workspaceKind: workspaceKind)
                }
                else {
                    // no layer for this source, remove source and retry
                    style.removeSource(source)
                    add_source = true
                }
            }
            else {
                // nothing ever added
                add_source = true
            }
            
            if(add_source) {
                addSourceAndLayerFromProductFeature(sourceID: source_id,
                                                    layerID: layer_id,
                                                    style: style,
                                                    feature: feature,
                                                    aoiColor: aoiColor,
                                                    workspaceKind: workspaceKind)
            }
        }
    }
    
    
    private func addSourceAndLayerFromProductFeature(sourceID: String,
                                                     layerID: String,
                                                     style: MGLStyle,
                                                     feature: OAProductFeature,
                                                     aoiColor: UIColor,
                                                     workspaceKind: Int? = nil) {
        let default_layer_id = "default"
        let tile_matrix_set = "EPSG" + TILE_MATRIX_SET

        // this source was not added yet so get capabilities
        OneAtlas.sharedInstance()?.viewService.getWMTS(feature, with: { (capabilities:OACapabilities?, error:OAError?) in
            if let capabilities = capabilities {
                let layer = capabilities.tileLayers[default_layer_id]
                if let tms = capabilities.tileMatrixSets[tile_matrix_set] {

                    let options = [
                        MGLTileSourceOption.tileSize: 256,
                        MGLTileSourceOption.minimumZoomLevel: tms.minZoomLevel,
                        MGLTileSourceOption.maximumZoomLevel: tms.maxZoomLevel,
                    ]

                    let url_template = capabilities.wmtsTemplateURL(withTileMatrixSet: tile_matrix_set,
                                                                    layerID: default_layer_id,
                                                                    useXYZ: true)!
                    let rts = MGLRasterTileSource(identifier: sourceID,
                                                  tileURLTemplates: [url_template],
                                                  options: options)
                    
                    // add layer+source (if not present)
                    let rsl = MGLRasterStyleLayer(identifier: layerID,
                                                  source: rts)
                    
                    if style.sources.firstIndex(of: rts) == nil {
                        style.addSource(rts)
                        
                        // insert layer after last custom layer
                        if let top_layer = style.layers.last(where: { (layer:MGLStyleLayer) -> Bool in
                            return layer.identifier.starts(with: LAYER_PREFIX)
                        }) {
                            style.insertLayer(rsl, above: top_layer)
                            
                            // cache layer
                            self._streamCache[layerID] = layer
                            
                            self.addedStreamFromProductFeatureCompletion(feature,
                                                                         shapeColor: aoiColor,
                                                                         workspaceKind: workspaceKind)
                        }
                    }
                }
                else {
                    // no webmercator tile matrix set !
                    // show error message
                    self._delegate?.addedStreamFromFeature(feature,
                                                           workspaceKind: workspaceKind,
                                                           error: error)
                }
            }
            else {
                if let error = error {
                    // getWMTS error
                    self._delegate?.addedStreamFromFeature(feature,
                                                           workspaceKind: workspaceKind,
                                                           error: error)
                }
            }
        })
    }
   
        
    private func addedStreamFromProductFeatureCompletion(_ feature: OAProductFeature,
                                                         shapeColor:UIColor,
                                                         workspaceKind:Int?) {
        
        // always show polygon around bounding box
        if let polygon = feature.geometry as? OAPolygon {
            self.addAOIShape(polygon: polygon,
                             type: .stream,
                             color: shapeColor)
        }
        
        // notify
        self._delegate?.addedStreamFromFeature(feature,
                                               workspaceKind: workspaceKind,
                                               error: nil)
    }
    
    
    func removeStream() {
        // remove AOI
        removeAOIShape(type: .stream)

        // hide stream
        if let style = _mapView.style {
            for (layerID, _) in self._streamCache {
                let layer = style.layer(withIdentifier: layerID)
                layer?.isVisible = false
            }
        }
    }
    
    
    // =========================================================================
    // MARK: - Layer Control
    // =========================================================================
    func showLayer(_ layer:EMapLayer) {
        if let style = _mapView.style {
            // loop thru all my custom layers, hide them except the one we want
            for l in style.layers {
                if l.identifier.starts(with: LAYER_PREFIX) {
                    l.isVisible = (l.identifier == LAYER_PREFIX + layer.rawValue)
                }
            }
        }
    }
    
    
    private func setupAllLayers() {
        if let style = _mapView.style {
            OneAtlas.sharedInstance()?.dataService.getOneLiveCapabilities({ (capabilities:OACapabilities?, error:OAError?) in
                
                if let capabilities = capabilities {
                    if let tms = capabilities.tileMatrixSets[TILE_MATRIX_SET] {
                        let min_zoom = NSNumber(value: tms.minZoomLevel)
                        let max_zoom = NSNumber(value: tms.maxZoomLevel)
                        
                        // now loop thru OneAtlas layer types and add them to engine
                        for layer in EMapLayer.allCases {
                            if layer.isOneAtlas() {
                                let oneatlas_url_template = capabilities.wmtsTemplateURL(withTileMatrixSet: TILE_MATRIX_SET,
                                                                                         layerID: layer.rawValue,
                                                                                         useXYZ: true)
                                let options = [
                                    MGLTileSourceOption.tileSize: 256,
                                    MGLTileSourceOption.maximumZoomLevel: max_zoom,
                                    MGLTileSourceOption.minimumZoomLevel: min_zoom
                                ]
                                
                                let oneatlas_source = MGLRasterTileSource(identifier: layer.rawValue + "-source",
                                                                          tileURLTemplates: [oneatlas_url_template ?? ""],
                                                                          options: options)
                                
                                let oneatlas_layer = MGLRasterStyleLayer(identifier: LAYER_PREFIX + layer.rawValue,
                                                                         source: oneatlas_source)
                                oneatlas_layer.isVisible = false
                                
                                style.addSource(oneatlas_source)
                                if let marker_layer = style.layer(withIdentifier: "com.mapbox.annotations.points") {
                                    // insert custom layer below POIs
                                    style.insertLayer(oneatlas_layer, below: marker_layer)
                                }
                                else {
                                    style.addLayer(oneatlas_layer)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    
    // =========================================================================
    // MARK: - Camera Control
    // =========================================================================
    private func bounds(fromCenter center:CLLocationCoordinate2D,
                        span:CLLocationDegrees) -> MGLCoordinateBounds {
        let sw = CLLocationCoordinate2DMake(center.latitude - span, center.longitude - span)
        let ne = CLLocationCoordinate2DMake(center.latitude + span, center.longitude + span);
        return MGLCoordinateBoundsMake(sw, ne);
    }
    
    
    func flyCameraToCoordinate(coord:CLLocationCoordinate2D,
                               span:CLLocationDegrees = MapEngineConfig.defaultSpanDegrees,
                               duration:TimeInterval = MapEngineConfig.cameraAnimDuration) {

        let camera = _mapView.cameraThatFitsCoordinateBounds(bounds(fromCenter: coord, span: span))
        _mapView.fly(to: camera, withDuration: duration) {
            self._delegate?.cameraDidFly(toCoordinate: coord)
        }
    }
    
    
    func flyCameraToRegion(region:MapRectangularRegion,
                           edgeInsets:UIEdgeInsets? = nil,
                           duration:TimeInterval = MapEngineConfig.cameraAnimDuration) {
        let bounds = MGLCoordinateBounds.init(sw: region.sw, ne: region.ne)
        let sz = CGFloat(16)
        let padding = edgeInsets ?? UIEdgeInsets(top: sz, left: sz, bottom: sz, right: sz)
        
        let camera = _mapView.cameraThatFitsCoordinateBounds(bounds, edgePadding: padding)
        _mapView.fly(to: camera, withDuration: duration) {
            let lat = region.sw.latitude + (fabs(region.ne.latitude - region.sw.latitude) / 2)
            let lon = region.sw.longitude + (fabs(region.ne.longitude - region.sw.longitude) / 2)
            self._delegate?.cameraDidFly(toCoordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
    }
    
    
    func restoreCamera(duration:TimeInterval = MapEngineConfig.cameraAnimDuration) {
        if let pc = _previousCamera {
            _mapView.fly(to: pc, withDuration: duration, completionHandler: nil)
            _previousCamera = nil
        }
    }
    
    
    func adjustCameraToEdgeInsets(_ edgeInsets:UIEdgeInsets,
                                  span:CLLocationDegrees = MapEngineConfig.defaultSpanDegrees,
                                  duration:TimeInterval = MapEngineConfig.cameraAnimDuration) {
    
        // adjust camera if POI or AOI is displayed
        if let aoi = _mapView.annotations?.first(where: { (annotation) -> Bool in
            return annotation is AOIShape
        }) as? AOIShape {
            // there's an AOI displayed, zoom on that
            _previousCamera = _mapView.camera;
            
            // get AOI bounding box
            if let bbox = aoi.polygon?.boundingBox(),
                bbox.count == 2 {
                let bounds = MGLCoordinateBounds(sw: bbox[0].coordinate, ne: bbox[1].coordinate)
                let camera = _mapView.cameraThatFitsCoordinateBounds(bounds,
                                                                     edgePadding: edgeInsets)
                _mapView.fly(to: camera, withDuration: duration, completionHandler: nil)
            }
        
        }
        else if let _ = _mapView.annotations?.first(where: { (annotation) -> Bool in
            return annotation is POIAnnotation
        }) {
            // there's a POI displayed, zoom on that
            _previousCamera = _mapView.camera;
            let center = _poiAnnotation.coordinate
            let camera = _mapView.cameraThatFitsCoordinateBounds(bounds(fromCenter: center,
                                                                        span: span),
                                                                 edgePadding: edgeInsets)
            _mapView.fly(to: camera, withDuration: duration, completionHandler: nil)
        }
    }
}


// =============================================================================
// MARK: - MGLMapViewDelegate
// =============================================================================
extension MapboxEngineManager: MGLMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        setupAllLayers()
        mapView.setCenter(CLLocationCoordinate2D(latitude: MapEngineCache.lastLatitude,
                                                 longitude: MapEngineCache.lastLongitude),
                          zoomLevel: MapEngineCache.lastZoom,
                          animated: false)
        
        _delegate?.mapEngineDidFinishLoading(map: mapView, error: nil)
    }
    
    
    func mapViewDidFailLoadingMap(_ mapView: MGLMapView, withError error: Error) {
        _delegate?.mapEngineDidFinishLoading(map: mapView, error: error)
    }
    

    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    }

    
    func mapView(_ mapView: MGLMapView, regionWillChangeWith reason: MGLCameraChangeReason, animated: Bool) {
        if reason != .programmatic {
            // used moved camera: do not restore camera when asked
            _previousCamera = nil;
            
            // notify
            _delegate?.userWillMoveMap()
        }
    }
    
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        // notify
        _delegate?.userIsMovingMap()
    }
    
    
    func mapView(_ mapView: MGLMapView,
                 regionDidChangeWith reason: MGLCameraChangeReason,
                 animated: Bool) {
        // notify
        if reason != .programmatic && reason.isEmpty == false {
            
            print("HAZ COORDZ \(mapView.centerCoordinate))")
            print("HAZ Z \(mapView.zoomLevel))")

            
            MapEngineCache.lastLatitude = mapView.centerCoordinate.latitude
            MapEngineCache.lastLongitude = mapView.centerCoordinate.longitude
            MapEngineCache.lastZoom = mapView.zoomLevel

            print("SAVED COORDZ \(CLLocationCoordinate2D(latitude: MapEngineCache.lastLatitude, longitude: MapEngineCache.lastLongitude))")
            print("SAVED Z \(MapEngineCache.lastZoom))")

            _delegate?.userDidMoveMap()
        }
    }
    

    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return CGFloat(1)
    }
    
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        var ret = UIColor.clear
        if let aoi = annotation as? AOIShape {
            ret = aoi.color
        }
        return ret
    }
}


extension MapboxEngineManager: UIGestureRecognizerDelegate {

    // we want "double tap" (zoom) to cancel "single tap"
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        var ret = false
        if let double_tap = otherGestureRecognizer as? UITapGestureRecognizer,
            let single_tap = gestureRecognizer as? UITapGestureRecognizer {
            ret = (double_tap.numberOfTapsRequired == 2 && single_tap.numberOfTapsRequired == 1)
        }
        return ret
    }
}
