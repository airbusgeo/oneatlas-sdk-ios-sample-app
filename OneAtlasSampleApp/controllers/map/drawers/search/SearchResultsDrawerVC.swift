//
//  SearchResultsDrawerVC.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 19/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import MapboxGeocoder
import Pulley
import OneAtlas


protocol SearchResultsDrawerDelegate: BaseDrawerDelegate {
    func onSearchResultsCancelClicked()
    func onSearchResultsFeatureSelected(_ feature:OAFeature, workspaceKind:EWorkspaceKind)
    func onSearchResultsAOISelected(_ aoi:OAUserAOI, workspaceKind:EWorkspaceKind)
}


class SearchResultsDrawerVC: BaseDrawerVC {

    @IBOutlet weak var uvWorkspace: UIMultiWorkspaceListView!
    @IBOutlet weak var uvSearchHeader: UISearchDrawerHeader!
    
    var delegate:SearchResultsDrawerDelegate?
    
    var criteria = SearchFilterCriteria() {
        didSet {
            startRefresh()
            uvWorkspace.criteria = criteria
        }
    }
    
    var geometry:OAGeometry? {
        didSet {
            startRefresh()
            uvWorkspace.geometry = geometry
        }
    }
    
    
    override var title: String? {
        didSet {
            uvSearchHeader.title = title ?? ""
        }
    }
    
    
    func startRefresh() {
        uvSearchHeader.isLoading = true
    }
    
    
    func stopRefresh() {
        
        if let polygon = geometry as? OAPolygon,
            let center = polygon.centroid()?.coordinate {
            uvSearchHeader.subtitle1 = String(format: "Center: %@", GeoUtils.coordinateString(coord: center))
            uvSearchHeader.subtitle2 = String(format: "Area: %@", GeoUtils.areaString(polygon: polygon))
            
        }
        else if let point = geometry as? OAPoint {
            uvSearchHeader.subtitle1 = String(format: "Center: %@", GeoUtils.coordinateString(coord: point.coordinate))
            uvSearchHeader.subtitle2 = ""
        }
        uvSearchHeader.isLoading = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uvWorkspace.delegate = self
        uvSearchHeader.delegate = self
    }

    
    func addWorkspaceID(_ workspaceID:String,
                        kind:EWorkspaceKind,
                        processingLevel:EProcessingLevel? = nil) {
        uvWorkspace.addWorkspaceID(workspaceID, kind: kind, processingLevel: processingLevel)
    }
}


// =============================================================================
// MARK: - PulleyDrawerViewControllerDelegate
// =============================================================================
extension SearchResultsDrawerVC {
    override func drawerPositionDidChange(drawer: PulleyViewController,
                                          bottomSafeArea: CGFloat) {
        super.drawerPositionDidChange(drawer: drawer, bottomSafeArea: bottomSafeArea)

        uvWorkspace.isScrollEnabled = (drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel)

        delegate?.onDrawerPositionDidChange(position: drawer.drawerPosition)
    }
}


// =============================================================================
// MARK: - UIMultiWorkspaceListViewDelegate
// =============================================================================
extension SearchResultsDrawerVC: UIMultiWorkspaceListViewDelegate {
    
//    func onMultiWorkspaceListViewWillRefresh() {
//        // TODO: will refresh
//    }
    
    func onMultiWorkspaceListViewItemSelected(_ kind:EWorkspaceKind, item: Any) {
        // TODO: hide me to avoid multiselection while loading
        if let feature = item as? OAFeature {
            delegate?.onSearchResultsFeatureSelected(feature, workspaceKind:kind)
        }
        else if let aoi = item as? OAUserAOI {
            delegate?.onSearchResultsAOISelected(aoi, workspaceKind:kind)
        }
    }
    
    func onMultiWorkspaceListViewDidRefresh(_ kind:EWorkspaceKind, count: Int, error: Error?) {
        stopRefresh()
        
        // partially show drawer if there is some data to show
        if count > 0 && pulleyViewController?.drawerPosition != .open {
            setPosition(.partiallyRevealed)
        }
    }
}


// =============================================================================
// MARK: - SearchResultsFilterDelegate
// =============================================================================
extension SearchResultsDrawerVC: SearchResultsFilterDelegate {
    func onSearchResultsFilterChanged(_ aSearchResultsFilter: SearchResultsFilterVC,
                                      criteria aCriteria: SearchFilterCriteria) {
        criteria = aCriteria
        uvSearchHeader.isBadgeHidden = aCriteria.isDefault
    }
}


// =============================================================================
// MARK: - UISearchDrawerHeaderDelegate
// =============================================================================
extension SearchResultsDrawerVC: UISearchDrawerHeaderDelegate {
    func onCancelClicked() {
        delegate?.onSearchResultsCancelClicked()
    }
    func onFilterClicked() {
        let vc = SearchResultsFilterVC.fromXib() as! SearchResultsFilterVC
        vc.delegate = self
        vc.criteria = criteria
        present(vc, animated: true, completion: nil)
    }
}
