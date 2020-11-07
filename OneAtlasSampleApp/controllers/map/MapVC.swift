//
//  MapVC.swift
//
//  Copyright © 2019 Airbus. All rights reserved.
//

import UIKit

import Mapbox
import Pulley
import MapboxGeocoder

import OneAtlas


// =============================================================================
// MARK: - MapPresenter
// =============================================================================
protocol MapPresenterContract {
    func performReverseGeocoding(fromCoordinate coord:CLLocationCoordinate2D,
                                 reason:EMapInteractionReason)
    func requestStreamFromFeatureID(_ featureID:String)
}


class MapPresenter: MapPresenterContract {
    
    private var _mapView:MapViewContract
    init(mapView:MapViewContract) {
        _mapView = mapView
    }
    
    
    func performReverseGeocoding(fromCoordinate coord:CLLocationCoordinate2D,
                                 reason:EMapInteractionReason) {
        GeoUtils.performReverseGeocoding(coord: coord) { (placemark:GeocodedPlacemark?, error:NSError?) in
            if let error = error {
                self._mapView.showError(error.localizedDescription)
            }
            else if let placemark = placemark {
                self._mapView.addPlacemark(placemark, reason: reason)
            }
        }
    }
    
    
    func requestStreamFromFeatureID(_ featureID:String) {

        _mapView.resetMap()
        
        // grab feature
        OneAtlas.shared.searchService?.openSearch(id: featureID,
                                                  block: { (feature: Feature?, error: Error?) in
            if let error = error {
                self._mapView.showError(error.localizedDescription)
            }
            else if let pf = feature as? ProductFeature {
                self._mapView.displayProductFeature(pf,
                                                    workspaceKind: .myImages)
            }
        })
    }
}


// =============================================================================
// MARK: - MapVC
// =============================================================================
enum EMapInteractionReason: Int {
    case pinAddedByLongpress = 0, pinAddedBySearch
}


protocol MapViewContract {
    func zoomToPlacemark(_ placemark:GeocodedPlacemark)
    func addPlacemark(_ placemark:GeocodedPlacemark, reason:EMapInteractionReason)
    func displayProductFeature(_ productFeature:ProductFeature, workspaceKind:EWorkspaceKind)
    func displayUserAOI(_ aoi: UserAOI)
    func displayViewportAOI()
    func resetMap()
    func showError(_ message: String?)
}


protocol MapDelegate {
    
}


class MapVC: UIViewController {
    
    @IBOutlet var mglMap: MGLMapView!
    @IBOutlet weak var btFloating: UIFloatingMapButton!
    
    private var _drawerManager:DrawerManager?
    private var _mapEngine: MapEngineContract?
    private var _presenter:MapPresenterContract?
    private var _isVisibleUI = true
    private var _mapReady = false
    private var _expandTimer:Timer?
    private let _selectionFeedback = UISelectionFeedbackGenerator()
    
    var delegate:MapDelegate?
    
    @IBOutlet var uvFloatingBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mglMap.compassViewPosition = .topLeft
        mglMap.compassViewMargins = CGPoint(x: 8, y: 20)
        _mapEngine = MapEngineManager.managerForMapView(mglMap,
                                                        delegate: self)
        _presenter = MapPresenter.init(mapView: self)
        

        btFloating.clipsToBounds = true
        btFloating.layer.cornerRadius = Config.defaultCornerRadius
        btFloating.tintColor = Color.textWhite.value
        
        showUI(enable: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pulleyViewController?.displayMode = .automatic
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let searchDrawer = pulleyViewController?.drawerContentViewController as? SearchDrawerVC {
            _drawerManager = DrawerManager.init(withRootDrawer: searchDrawer)
            searchDrawer.delegate = self
        }
    }
    
    
    @IBAction func onFloatingButtonClicked(_ sender: Any) {
        // haptic feedback
        _selectionFeedback.selectionChanged()
        
        switch btFloating.buttonState {
        case .search, .searchCollapsed:
            displayViewportAOI()
        }
    }
    
    
    private var defaultMapEdgeInsets:UIEdgeInsets {
        get {
            let sz = CGFloat(32)
            let b = pulleyViewController?.drawerDistanceFromBottom.distance ?? 0
            return UIEdgeInsets(top: sz, left: sz, bottom: sz + b, right: sz)
        }
    }
    
    
    private func showUI(enable:Bool) {
        UIView.animate(withDuration: Config.animDurationFast) {
            self._isVisibleUI = enable
        }
    }
}



// =============================================================================
// MARK: - MapEngineManagerDelegate
// =============================================================================
extension MapVC: MapEngineManagerDelegate {
    func mapEngineDidFinishLoading(map: UIView, error: Error?) {
        if let error = error {
            ToastUtils.showError(error.localizedDescription)
        }
        else {
            // no location request. show help ?
            if CacheUtils.mapDidDeclineHelp == false {
                // show help
                present(MapHelpVC.fromXib(), animated: true, completion: nil)
            }
            
            _mapReady = true
            showUI(enable: true)
        }
    }
    
    func userDidTapMap(atCoordinate coord: CLLocationCoordinate2D) {
        _drawerManager?.toggleDisplay()
        showUI(enable: !_isVisibleUI)
    }
    
    func userDidLongpressMap(atCoordinate coord: CLLocationCoordinate2D) {
        // haptic feedback
        _selectionFeedback.selectionChanged()
        
        // force show UI
        showUI(enable: true)
        
        // add marker immediately and reverse geocode
        _mapEngine?.setPOIAnnotation(atCoordinate: coord, title: "My marker", subtitle: nil)
        _presenter?.performReverseGeocoding(fromCoordinate:coord, reason: .pinAddedByLongpress)
    }
    
    
    func userWillMoveMap() {
        // remove auto-expand floating button timer
        _expandTimer?.invalidate()
        _expandTimer = nil
        
        // collapse floating button
        switch btFloating.buttonState {
        case .search:
            btFloating.animation = .transitionFlipFromLeft
            btFloating.buttonState = .searchCollapsed
        default:
            break
        }
        
        // change drawer position
        if _isVisibleUI {
            _drawerManager?.setPosition(.collapsed)
        }
    }
    
    
    func userIsMovingMap() {
    }
    
    
    func userDidMoveMap() {
        _expandTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (t) in
            let state = self.btFloating.buttonState
            if state == .searchCollapsed {
                self.btFloating.animation = .transitionFlipFromLeft
                self.btFloating.buttonState = .search
            }
        }
    }
    
    
    func addedStreamFromFeature(_ feature: ProductFeature,
                                workspaceKind streamKind: Int?,
                                error: Error?) {
        if let error = error {
            ToastUtils.showError(error.localizedDescription)
        }
        else {
            // show search details drawer
            if let vc = FeatureDetailsDrawerVC.fromXib() as? FeatureDetailsDrawerVC {
                vc.delegate = self
                
                _drawerManager?.push(drawer: vc, position: .partiallyRevealed, completion: { (finished) in
                    let wk = EWorkspaceKind(rawValue: streamKind ?? 0)
                    vc.workspaceKind = wk
                    vc.feature = feature
                    
                    self._mapEngine?.adjustCameraToEdgeInsets(self.mapEdgeInsets,
                                                              span: Config.defaultSpanDegrees,
                                                              duration: Config.animDurationSlow)
                })
            }
        }
    }
    
    
    func cameraDidFly(toCoordinate coord: CLLocationCoordinate2D) {
    }
}


// =============================================================================
// MARK: - MapViewContract
// =============================================================================
extension MapVC: MapViewContract {
    func addPlacemark(_ placemark: GeocodedPlacemark,
                      reason: EMapInteractionReason) {
        
        // show product features in drawer
        if let center = placemark.location?.coordinate {
            let point = Point(latitude: center.latitude, longitude: center.longitude)
            _drawerManager?.showSearchResultDrawer(geometry: point,
                                                   title: placemark.name,
                                                   delegate: self)

            // zoom to placemark if pin was added by search engine
            if reason == .pinAddedBySearch {
                _mapEngine?.setPOIAnnotation(atCoordinate: center, title: nil, subtitle: nil)
                zoomToPlacemark(placemark)
            }
        }
    }
    
    
    func zoomToPlacemark(_ placemark:GeocodedPlacemark) {
        if let region = placemark.region as? RectangularRegion {
            
            let rr = MapRectangularRegion(sw: region.southWest,
                                          ne: region.northEast)
            _mapEngine?.flyCameraToRegion(region: rr,
                                          edgeInsets: defaultMapEdgeInsets,
                                          duration: Config.animDurationSlow)
        }
        else if let center = placemark.location?.coordinate {
            _mapEngine?.flyCameraToCoordinate(coord: center,
                                              span: Config.defaultSpanDegrees,
                                              duration: Config.animDurationSlow)
        }
    }
    
    
    func displayProductFeature(_ productFeature: ProductFeature,
                               workspaceKind:EWorkspaceKind) {
        // map may NOT be initialized at this point !
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (t) in
            if self._mapReady == true {
                let idx:Int = workspaceKind.rawValue
                self._mapEngine?.addStreamFromProductFeature(productFeature,
                                                             aoiColor: workspaceKind.color,
                                                             workspaceKind: idx)
                t.invalidate()
            }
            else {
                print("MAP NOT READY -> WAIT...")
            }
        }
    }

    
    func displayProductFeature(_ productFeatureID: String) {
        _presenter?.requestStreamFromFeatureID(productFeatureID)
    }
    
    
    func displayViewportAOI() {
        if let polygon = _mapEngine?.polygonForCurrentViewport(edgeInsets: defaultMapEdgeInsets) {
            
            // remove streams
            _mapEngine?.removeStream()
            
            // build aoi
            _mapEngine?.addAOIShapeForCurrentViewport(edgeInsets: defaultMapEdgeInsets,
                                                      type: .search,
                                                      title: nil,
                                                      color: .clear)
            
            _drawerManager?.showSearchResultDrawer(geometry: polygon,
                                                   title: Config.loc("aoi_type_" + EAOIType.search.rawValue),
                                                   delegate: self)
        }
    }
    

    func displayUserAOI(_ aoi: UserAOI) {

        // remove all, streams & shapes
        resetMap()
        
        // add AOI
        _mapEngine?.addAOIShape(polygon: aoi,
                                type: .user,
                                title: aoi.name,
                                color: Config.appColor)
        
        // fly to AOI
        let region = MapRectangularRegion(sw: CLLocationCoordinate2D.from(point: aoi.boundingBox.southWest),
                                          ne: CLLocationCoordinate2D.from(point: aoi.boundingBox.northEast))
        _mapEngine?.flyCameraToRegion(region: region,
                                      edgeInsets: defaultMapEdgeInsets,
                                      duration: Config.animDurationSlow)

        
        // show search results
        _drawerManager?.showSearchResultDrawer(geometry: aoi,
                                               title: aoi.name,
                                               delegate: self)
    }

    
    func resetMap() {
        // reset floating button
        btFloating.resetToDefaultState()
        
        // pop to root drawer
        _drawerManager?.popToRootDrawer(defaultPosition: .collapsed,
                                        completion: nil)
        
        // remove streams, AOIs, POIs...
        _mapEngine?.removePOIAnnotation()
        _mapEngine?.removeStream()
        for shape in EAOIType.allCases {
            _mapEngine?.removeAOIShape(type: shape)
        }
    }
    
    
    func showError(_ message: String?) {
        ToastUtils.showError(message ?? Config.loc("g_error_occured"))
    }
}



// =============================================================================
// MARK: - PulleyPrimaryContentControllerDelegate
// =============================================================================
extension MapVC: PulleyPrimaryContentControllerDelegate {
        
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        guard drawer.currentDisplayMode == .drawer else {
            uvFloatingBottomConstraint.constant = DEFAULT_MAP_PADDING
            return
        }
        
        // adjust constraint for floating button
        let threshold_height = drawer.partialRevealDrawerHeight(bottomSafeArea: bottomSafeArea)
        if distance <= threshold_height {//} 268.0 + bottomSafeArea {
            // show
            uvFloatingBottomConstraint.constant = distance + DEFAULT_MAP_PADDING
        }
        else {
            // hide
            uvFloatingBottomConstraint.constant = /*268.0 + bottomSafeArea*/threshold_height + DEFAULT_MAP_PADDING
        }
        
    }
    
    
    var mapEdgeInsets:UIEdgeInsets {
        get {
            let distance = pulleyViewController?.drawerDistanceFromBottom.distance ?? 0
            let bsa = pulleyViewController?.drawerDistanceFromBottom.bottomSafeArea ?? 0
            
            let bottom = mglMap.bounds.size.height - (distance + bsa + DEFAULT_MAP_PADDING + DEFAULT_MAP_PADDING)
            print("MAP EDGE INSETS bottom = \(bottom)")
            return UIEdgeInsets(top: DEFAULT_MAP_PADDING,
                                left: DEFAULT_MAP_PADDING,
                                bottom: bottom,
                                right: DEFAULT_MAP_PADDING)
        }
    }
}


// =============================================================================
// MARK: - BaseDrawerDelegate
// =============================================================================
extension MapVC: BaseDrawerDelegate {
    func onDrawerPositionDidChange(position: PulleyPosition) {
        switch position {
        case .partiallyRevealed:
            _mapEngine?.adjustCameraToEdgeInsets(mapEdgeInsets, span: Config.defaultSpanDegrees, duration: Config.animDurationSlow)
        case .collapsed:
            _mapEngine?.restoreCamera(duration: Config.animDurationSlow)
        default:
            break
        }
    }
}


// =============================================================================
// MARK: - SearchDrawerDelegate
// =============================================================================
extension MapVC: SearchDrawerDelegate {
    
    // clicked on search result in search bar
    func onSearchPlacemarkSelected(placemark: GeocodedPlacemark) {
        _selectionFeedback.selectionChanged()
        addPlacemark(placemark, reason: .pinAddedBySearch)
    }
    
    
    // clicked on 'search' button of virtual keyboard
    func onSearchButtonClicked(placemark: GeocodedPlacemark?) {
        if let placemark = placemark {
            // grab 1st placemark, and do as if we selected it
            _selectionFeedback.selectionChanged()
            addPlacemark(placemark, reason: .pinAddedBySearch)
        }
        else {
            // empty results, reduce drawer
            _drawerManager?.setPosition(.collapsed)
        }
    }
    
    
    func onSearchCancelClicked() {
        // _mapEngine?.removePOIAnnotation()
    }
    
    
    func onSearchClearClicked() {
        // remove POI
        _mapEngine?.removePOIAnnotation()
    }
}


// =============================================================================
// MARK: - SearchResultsDrawerDelegate
// =============================================================================
extension MapVC: SearchResultsDrawerDelegate {
    func onSearchResultsFeatureSelected(_ feature: Feature,
                                        workspaceKind:EWorkspaceKind) {
        // add stream to map engine
        if let pf = feature as? ProductFeature {
            _selectionFeedback.selectionChanged()
            displayProductFeature(pf, workspaceKind:workspaceKind)
        }
    }
    
    
    func onSearchResultsAOISelected(_ aoi: UserAOI,
                                    workspaceKind: EWorkspaceKind) {
        _selectionFeedback.selectionChanged()
        displayUserAOI(aoi)
    }
    
    
    func onSearchResultsCancelClicked() {
        // remove steams, AOIs & POIs
        resetMap()

        // restore search drawer
        _drawerManager?.popToRootDrawer(defaultPosition: .collapsed, completion: nil)
    }
}


// =============================================================================
// MARK: - FeatureDetailsDrawerDelegate
// =============================================================================
extension MapVC: FeatureDetailsDrawerDelegate {
    
    func onFeatureDetailsCancelClicked(feature: Feature) {
        // restore search results
        _mapEngine?.removeStream()
        let _ = _drawerManager?.popDrawer(defaultPosition: nil, completion: nil)
        
        btFloating.animation = .transitionFlipFromTop
        btFloating.buttonState = .search
    }
}
