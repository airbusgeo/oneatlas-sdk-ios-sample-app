//
//  UIWorkspaceListView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 18/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import OneAtlas


// =============================================================================
// MARK: - UIWorkspaceListViewDelegate
// =============================================================================
protocol UIWorkspaceListViewDelegate {
    func onWorkspaceListViewDidRefresh(_ count: Int, error:Error?)
    func onWorkspaceListViewWillRefresh()
}


// =============================================================================
// MARK: - UIWorkspaceListView
// =============================================================================
class UIWorkspaceListView: UICountingListView {

    var delegate:UIWorkspaceListViewDelegate?
    
    var tableDelegate:UITableViewDelegate? {
        didSet {
            tvResults.delegate = tableDelegate
        }
    }
    
    var isScrollEnabled:Bool = true {
        didSet {
            tvResults.isScrollEnabled = isScrollEnabled
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // setup specific table and cells
        UIFeatureTableCell.registerNibIntoTable(tvResults)
//        UIUserAOITableCell.registerNibIntoTable(tvResults)
        if let table = tvResults as? UIWorkspaceTableView {
            table.workspaceDelegate = self
        }
    }
    
    
    // specific reset method
    func resetWithGeometry(_ geometry: Geometry? = nil,
                           workspaceKind: EWorkspaceKind,
                           workspaceID: String,
                           processingLevel: EProcessingLevel? = nil,
                           criteria: SearchFilterCriteria) {
        showLoading()
        if let table = tvResults as? UIWorkspaceTableView {
            table.resetWithGeometry(geometry,
                                    workspaceKind: workspaceKind,
                                    workspaceID: workspaceID,
                                    processingLevel: processingLevel,
                                    criteria: criteria)
        }
    }
}




// =============================================================================
// MARK: - UIWorkspaceTableViewDelegate
// =============================================================================
extension UIWorkspaceListView: UIWorkspaceTableViewDelegate {

    func onWorkspaceTableViewWillReset() {
        delegate?.onWorkspaceListViewWillRefresh()
    }
    
    func onWorkspaceTableViewDidReset(count: Int, error: Error?) {
        showCount(count, error: error)
        delegate?.onWorkspaceListViewDidRefresh(count, error: error)
    }
}
