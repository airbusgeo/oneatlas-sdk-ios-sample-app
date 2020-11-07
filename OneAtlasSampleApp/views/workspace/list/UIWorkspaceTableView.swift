//
//  UIMyWorkspaceTableView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 26/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import OneAtlas


protocol UIWorkspaceTableViewDelegate {
    func onWorkspaceTableViewWillReset()
    func onWorkspaceTableViewDidReset(count:Int, error:Error?)
}

class UIWorkspaceTableView: UIPagingTableView {
    
    private var _geometry: Geometry?
    private var _criteria = SearchFilterCriteria()
    private var _workspaceID:String?
    private var _workspaceKind:EWorkspaceKind?
    private var _processingLevel: EProcessingLevel?
    
    var workspaceDelegate:UIWorkspaceTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        pagingDelegate = self
        backgroundColor = .clear
    }
    

    func resetWithGeometry(_ geometry: Geometry? = nil,
                           workspaceKind: EWorkspaceKind,
                           workspaceID: String,
                           processingLevel: EProcessingLevel? = nil,
                           criteria: SearchFilterCriteria) {

        _geometry = geometry
        _criteria = criteria
        _workspaceID = workspaceID
        _workspaceKind = workspaceKind
        _processingLevel = processingLevel
        reset()
    }
    
    
    override func reset() {
        workspaceDelegate?.onWorkspaceTableViewWillReset()
        super.reset()
    }
}


// =============================================================================
// MARK: - UIPagingTableViewDelegate
// =============================================================================
extension UIWorkspaceTableView: UIPagingTableViewDelegate {

    func onPaginationDone(forPage page: Int, maxItems: Int, error: Error?) {
        if page == 0 {
            workspaceDelegate?.onWorkspaceTableViewDidReset(count: maxItems, error: error)
        }
    }
    
    
    func onPaginationRequested(forPage page: Int) {
        
        if _workspaceKind == .myAOIs {
            // special case: loop though my aois
            let total = UserManager.freemiumAOIs.count
            let start = page * Int(Config.defaultPagingTableCount)
            var end = start + Int(Config.defaultPagingTableCount)
            if end >= total {
                end = total - 1
            }
            if start < total {
                pagingCompletion(withItems: Array(UserManager.freemiumAOIs[start...end]),
                                 maxItems: total,
                                 error: nil)
            }
        }
        else if let workspaceID = _workspaceID {
            
            let filter = SearchFilter()

            filter.add(value: ERelation.intersects,
                       for: .relation)

            if let geometry = _geometry {
                filter.add(value: geometry,
                           for: .geometry)
            }

            if let minDate = _criteria.minDate {
                filter.set(minValue: minDate,
                           for: .acquisitionDate)
            }
            
            if let maxDate = _criteria.maxDate {
                filter.set(maxValue: maxDate,
                           for: .acquisitionDate)
            }

            filter.set(maxValue: Double(_criteria.maxAngle),
                       for: .cloudCover)

            filter.set(maxValue: Double(_criteria.maxAngle),
                       for: .incidenceAngle)

            if let res = Config.filterResolutions[_criteria.resolutionIndex] {
                filter.add(value: res,
                           for: .resolution)
            }

            if let processingLevel = _processingLevel {
                filter.set(value: processingLevel,
                           for: .processingLevel)
            }
 
            let sort = SearchSort()
            sort.add(criteria: .acquisitionDate,
                     order: .descending)
            
            OneAtlas.shared.searchService?.openSearch(into: workspaceID,
                                                      pagination: Pagination(page: page),
                                                      filter: filter,
                                                      sort: sort,
                                                      block: { (features: [Feature]?, pagination: Pagination?, error: Error?) in
                let total = Int(pagination?.totalItems ?? 0)
                self.pagingCompletion(withItems: features, maxItems: total, error: error)
            })
        }
    }
}


// =============================================================================
// MARK: - UITableViewDataSource
// =============================================================================
extension UIWorkspaceTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _items.count
    }
    
    
    // TODO: handle AOIs
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell:UITableViewCell?
        if let feature = _items[indexPath.row] as? ProductFeature {
            let ftc = tableView.dequeueReusableCell(withIdentifier: UIFeatureTableCell.identifier(), for: indexPath) as! UIFeatureTableCell
            ftc.feature = feature
            cell = ftc
        }
//        else if let aoi = _items[indexPath.row] as? UserAOI {
//            let uatc = tableView.dequeueReusableCell(withIdentifier: UIUserAOITableCell.identifier(), for: indexPath) as! UIUserAOITableCell
//            uatc.aoi = aoi
//            cell = uatc
//        }
        else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "")
        }
        cell!.backgroundColor = .clear
        return cell!
    }
}


