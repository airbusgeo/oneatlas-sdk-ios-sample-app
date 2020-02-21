//
//  UIMultiWorkspaceListView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 26/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit

import OneAtlas


// =============================================================================
// MARK: - EWorkspaceKind
// =============================================================================
enum EWorkspaceKind: Int {
    case livingLibrary
    case myImages
    case myAOIs
    case changeDetection
    
    func icon() -> UIImage {
        switch self {
        case .myImages:
            return UIImage.init(named: "baseline_perm_media_black_24pt")!
        case .livingLibrary:
            return UIImage.init(named: "baseline_image_search_black_24pt")!
        case .myAOIs:
            return UIImage.init(named: "baseline_crop_free_black_24pt")!
        case .changeDetection:
            return UIImage.init(named: "baseline_compare_black_24pt")!
        }
    }
    
    func countFormat() -> String {
        switch self {
        case .myImages, .livingLibrary:
            return Config.loc("bsearch_fmt_img_found")
        case .myAOIs:
            return Config.loc("bsearch_fmt_aoi_found")
        case .changeDetection:
            return Config.loc("bsearch_fmt_cd_found")
        }
    }
    
    
    var color: UIColor {
        var ret = UIColor.clear
        switch self {
            case .livingLibrary:
            ret = Config.appColor
        case .myImages:
            ret = AirbusColor.orders.value
        case .myAOIs, .changeDetection:
            ret = AirbusColor.workspace.value
        }
        return ret
    }
    
    
    func name() -> String {
        switch self {
        case .myImages:
            return Config.loc("bsearch_my_images")
        case .livingLibrary:
            return Config.loc("bsearch_living_library")
        case .myAOIs:
            return Config.loc("bsearch_my_aois")
        case .changeDetection:
            return Config.loc("bsearch_my_cd")
        }
    }
}


// ============================================================================
// MARK: - UIWorkspaceTabItem
// ============================================================================
private class UIWorkspaceTabItem : UITabBarItem {
    
    var countFormat:String = ""
    var workspaceID:String = ""
    var kind:EWorkspaceKind = .livingLibrary
    var processingLevel:EProcessingLevel?
    
    init(_ workspaceID:String, kind:EWorkspaceKind, processingLevel:EProcessingLevel? = nil) {
        super.init()
        self.workspaceID = workspaceID
        self.countFormat = kind.countFormat()
        self.kind = kind
        self.processingLevel = processingLevel
        title = kind.name()
        image = kind.icon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// =============================================================================
// MARK: - UIMultiWorkspaceListViewDelegate
// =============================================================================
protocol UIMultiWorkspaceListViewDelegate {
//    func onMultiWorkspaceListViewWillRefresh()
    func onMultiWorkspaceListViewDidRefresh(_ kind:EWorkspaceKind, count:Int, error:Error?)
    func onMultiWorkspaceListViewItemSelected(_ kind:EWorkspaceKind, item:Any)
}


// =============================================================================
// MARK: - UIMultiWorkspaceListView
// =============================================================================
class UIMultiWorkspaceListView: UIXibView {

    @IBOutlet weak var tbWorkspace: UITabBar!
    @IBOutlet weak var uvWorkspace: UIWorkspaceListView!
    
    var delegate:UIMultiWorkspaceListViewDelegate?
    
    var isScrollEnabled:Bool = true {
        didSet {
            uvWorkspace.isScrollEnabled = isScrollEnabled
        }
    }
    
    var geometry:OAGeometry? {
        didSet {
            refreshWorkspace()
        }
    }
    
    var criteria = SearchFilterCriteria() {
        didSet {
            refreshWorkspace()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        uvWorkspace.delegate = self
        uvWorkspace.tableDelegate = self
        
        tbWorkspace.delegate = self
        tbWorkspace.tintColor = Config.appColor
        tbWorkspace.backgroundImage = UIImage()
        tbWorkspace.backgroundColor = .clear
        tbWorkspace.shadowImage = UIImage()
        tbWorkspace.unselectedItemTintColor = AirbusColor.textLight.value
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // force apply xib-defined constraints
        self.contentView.frame = bounds
    }
    
    
    func addRefreshControl() {
        uvWorkspace.addRefreshControl()
    }
    
    
    func addWorkspaceID(_ workspaceID:String,
                        kind:EWorkspaceKind,
                        processingLevel:EProcessingLevel? = nil) {
        let item:UIWorkspaceTabItem = UIWorkspaceTabItem(workspaceID, kind: kind, processingLevel:processingLevel)
        self.tbWorkspace.items?.append(item)
        if tbWorkspace?.items?.count == 1 {
            // first item added, preselect
            tbWorkspace.selectedItem = item
        }
    }
    
    func refreshWorkspace() {
        
        if let workspaceItem = tbWorkspace.selectedItem as? UIWorkspaceTabItem {
            uvWorkspace.resetWithGeometry(geometry,
                                          workspaceKind: workspaceItem.kind,
                                          workspaceID: workspaceItem.workspaceID,
                                          processingLevel: workspaceItem.processingLevel,
                                          criteria: criteria)
        }
    }
}

// ============================================================================
// MARK: - UIWorkspaceListViewDelegate
// ============================================================================
extension UIMultiWorkspaceListView: UIWorkspaceListViewDelegate {
    
    func onWorkspaceListViewWillRefresh() {
//        delegate?.onMultiWorkspaceListViewWillRefresh()
    }
    
    func onWorkspaceListViewDidSelect(item: Any) {
        if let si = tbWorkspace.selectedItem as? UIWorkspaceTabItem {
            delegate?.onMultiWorkspaceListViewItemSelected(si.kind, item: item)
        }
    }
    
    func onWorkspaceListViewDidRefresh(_ count: Int, error: Error?) {
        if let workspaceItem = tbWorkspace.selectedItem as? UIWorkspaceTabItem {
            delegate?.onMultiWorkspaceListViewDidRefresh(workspaceItem.kind,
                                                         count: count,
                                                         error: error)
        }
    }
}


// =============================================================================
// MARK: - UITableViewDelegate
// =============================================================================
extension UIMultiWorkspaceListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var ret = UIAutoRegisterTableCell.DEFAULT_HEIGHT
        if let tab_item = tbWorkspace.selectedItem as? UIWorkspaceTabItem {
            switch tab_item.kind {
            case .livingLibrary, .myImages, .myAOIs:
                ret = UIFeatureTableCell.DEFAULT_HEIGHT
            default:
                break
            }
        }
        return ret
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let tab_item = tbWorkspace.selectedItem as? UIWorkspaceTabItem {
            if let cell = tableView.cellForRow(at: indexPath) as? UIFeatureTableCell {
                let feature = cell.feature
                delegate?.onMultiWorkspaceListViewItemSelected(tab_item.kind, item: feature as Any)
            }
            else if let cell = tableView.cellForRow(at: indexPath) as? UIUserAOITableCell {
                let aoi = cell.aoi
                delegate?.onMultiWorkspaceListViewItemSelected(tab_item.kind, item: aoi as Any)
            }
            else {
                // TODO: handle AOIs
            }
        }
    }
}


// ============================================================================
// MARK: - UITabBarDelegate
// ============================================================================
extension UIMultiWorkspaceListView : UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        refreshWorkspace()
    }
}
