//
//  BaseDrawerVC.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 19/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import Pulley
import MapboxGeocoder


protocol BaseDrawerDelegate {
    func onDrawerPositionDidChange(position:PulleyPosition)
}


class BaseDrawerVC: UIViewController {

    @IBOutlet weak var uvHeader: UIView!

    internal var _collapsedHeight:CGFloat {
        return uvHeader.frame.height
    }
    internal var _partiallyRevealedHeight:CGFloat {
        return 268.0
    }
    
    @IBOutlet var gripperTopConstraint: NSLayoutConstraint!

    @IBOutlet var gripperView: UIView!

    
    fileprivate var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gripperView.layer.cornerRadius = gripperView.bounds.height / 2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onHeaderClicked(_:)))
        uvHeader.addGestureRecognizer(tap)
    }
    
    
    @objc func onHeaderClicked(_ sender: Any) {
        if pulleyViewController?.drawerPosition == .collapsed { pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
        }
    }
    
    
    func setPosition(_ position:PulleyPosition) {
        pulleyViewController?.setDrawerPosition(position: position, animated: true, completion: { (finished) in
            
        })
    }
}


// =============================================================================
// MARK: - PulleyDrawerViewControllerDelegate
// =============================================================================
extension BaseDrawerVC: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return _collapsedHeight + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return _partiallyRevealedHeight + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all 
    }
    
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        drawerBottomSafeArea = bottomSafeArea
    }
    
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        
        print("Drawer: \(drawer.currentDisplayMode)")
        gripperTopConstraint.isActive = drawer.currentDisplayMode == .drawer
    }
}


class BaseTableDrawerVC: BaseDrawerVC {
    @IBOutlet var tableView: UITableView!

    
    override var drawerBottomSafeArea: CGFloat {
        didSet {
            self.loadViewIfNeeded()
            
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    
    override func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        super.drawerPositionDidChange(drawer: drawer, bottomSafeArea: bottomSafeArea)
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel
    }
}
