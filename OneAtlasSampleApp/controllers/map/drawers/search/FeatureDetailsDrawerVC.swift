//
//  FeatureDetailsDrawerVC.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 20/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import Pulley

import OneAtlas

protocol FeatureDetailsDrawerDelegate: BaseDrawerDelegate {
    func onFeatureDetailsCancelClicked(feature:OAFeature)
}

class FeatureDetailsDrawerVC: BaseDrawerVC {
    
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var uvFeature: UIFeatureSummaryView!
    @IBOutlet weak var tvProductFeature: UIFeatureDetailsTableView!
    
    
    var workspaceKind:EWorkspaceKind? {
        didSet {
            if let wk = workspaceKind {
                tvProductFeature.workspaceKind = wk
            }
        }
    }
    
    
    var feature:OAFeature? {
        didSet {
            uvFeature.feature = feature
            tvProductFeature.feature = feature
            uvFeature.isHidden = false
        }
    }
    var delegate:FeatureDetailsDrawerDelegate?
    
    override var _collapsedHeight:CGFloat {
        return 96
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIFeaturePropertyCell.registerNibIntoTable(tvProductFeature)
        
        btCancel.tintColor = AirbusColor.textLight.value
        
        uvFeature.isHidden = true
        
        uvFeature.feature = feature
    }
    
    @IBAction func onCancelClicked(_ sender: Any) {
        if let feature = feature {
            delegate?.onFeatureDetailsCancelClicked(feature: feature)
        }
    }
}


// =============================================================================
// MARK: - PulleyDrawerViewControllerDelegate
// =============================================================================
extension FeatureDetailsDrawerVC {
    override func drawerPositionDidChange(drawer: PulleyViewController,
                                          bottomSafeArea: CGFloat) {
        super.drawerPositionDidChange(drawer: drawer, bottomSafeArea: bottomSafeArea)
        
        tvProductFeature.isScrollEnabled = (drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel)
        
        delegate?.onDrawerPositionDidChange(position: drawer.drawerPosition)
    }
}
