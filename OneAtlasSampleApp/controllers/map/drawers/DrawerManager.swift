//
//  DrawerManager.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 26/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import Pulley
import MapboxGeocoder
import OneAtlas

class DrawerManager: NSObject {
    
    private var _prevPosition:PulleyPosition = .partiallyRevealed
    private var _drawerStack:[BaseDrawerVC] = []    
    
    func showSearchResultDrawer(geometry: Geometry,
                                title: String = "Marker placed",
                                delegate: SearchResultsDrawerDelegate,
                                position: PulleyPosition = .collapsed,
                                completion: PulleyAnimationCompletionBlock? = nil) {
        
        if let pvc = _drawerStack.last?.pulleyViewController {
            // get current displayed drawer
            if let top = _drawerStack.last as? SearchResultsDrawerVC {
                
                // this will trigger data refresh
                top.geometry = geometry
                top.title = title

                // move to position animated
                pvc.setDrawerPosition(position: position, animated: true, completion: { (reopen) in
                    completion?(reopen)
                })
            }
            else {
                // close animated
                pvc.setDrawerPosition(position: .closed, animated: true, completion: { (closed) in
                    // pop to root
                    self.popToRootDrawer()
                    
                    // push search result drawer
                    let sr = SearchResultsDrawerVC.fromXib() as! SearchResultsDrawerVC
                    sr.delegate = delegate

                    self._drawerStack.append(sr)
                    
                    // update pulley
                    pvc.setDrawerContentViewController(controller: sr, animated: false)
                    
                    // re-open animated
                    pvc.setDrawerPosition(position: position, animated: true, completion: { (reopen) in
                        
                        sr.addWorkspaceID(Config.livingLibraryWorkspaceID ?? "",
                                          kind: .livingLibrary,
                                          processingLevel: .sensor)
                        sr.addWorkspaceID(UserManager.workspaceID, kind: .myImages)

                        // this will trigger data refresh
                        sr.geometry = geometry
                        sr.title = title
                        completion?(reopen)
                    })
                })
            }
        }
    }
    
    
    init(withRootDrawer drawer:BaseDrawerVC) {
        super.init()
        _drawerStack.append(drawer)
    }
    
    
    final var topDrawer:BaseDrawerVC? {
        return _drawerStack.last
    }
    
    
    func toggleDisplay() {
        if let current = _drawerStack.last {
            if current.pulleyViewController?.drawerPosition == PulleyPosition.closed {
                current.pulleyViewController?.setDrawerPosition(position: _prevPosition, animated: true)
            }
            else {
                _prevPosition = current.pulleyViewController?.drawerPosition ?? .partiallyRevealed
                current.pulleyViewController?.setDrawerPosition(position: .closed, animated: true)
            }
        }
    }
    
    
    func setPosition(_ position:PulleyPosition) {
        if let current = _drawerStack.last {
            current.setPosition(position)
        }
    }
    
    
    func push(drawer: BaseDrawerVC,
              popToRoot: Bool = false,
              position: PulleyPosition?,
              completion: PulleyAnimationCompletionBlock?) {
        
        if popToRoot {
            
        }
        
        if let top = _drawerStack.last,
            let pvc = top.pulleyViewController {
            _drawerStack.append(drawer)
            print("DRAWER: pushDrawer \(String(describing: drawer))")
            showTopDrawer(defaultPosition: position, inPulley: pvc, completion: completion)
        }
    }
    
    
    func popDrawer(defaultPosition position:PulleyPosition?,
                   completion: PulleyAnimationCompletionBlock?) -> BaseDrawerVC? {
        var ret:BaseDrawerVC? = nil
        if _drawerStack.count > 1 {
            ret = _drawerStack.popLast()
            print("DRAWER: popDrawer \(String(describing: ret))")
            if let pulley = ret?.pulleyViewController {
                showTopDrawer(defaultPosition: position, inPulley: pulley, completion: completion)
            }
        }
        return ret
    }
    
    
    private func popToRootDrawer() {
        if _drawerStack.count > 0,
            let top = _drawerStack.last,
            let pvc = top.pulleyViewController {
            while _drawerStack.count > 1 {
                _drawerStack.removeLast()
            }
            
            if let root = _drawerStack.last {
                pvc.setDrawerContentViewController(controller: root, animated: false)
            }
        }
    }
    
    
    func popToRootDrawer(defaultPosition position:PulleyPosition?,
                         animated: Bool = true,
                         completion: PulleyAnimationCompletionBlock?) {
        if _drawerStack.count > 0,
            let top = _drawerStack.last,
            let pvc = top.pulleyViewController {
            print("DRAWER: popToRootDrawer")
            
            while _drawerStack.count > 1 {
                _drawerStack.removeLast()
            }
            
            if animated {
                showTopDrawer(defaultPosition: position, inPulley: pvc, completion: completion)
            }
            else {
                
            }
        }
    }
    
    
    private func showTopDrawer(defaultPosition position:PulleyPosition?,
                               inPulley pulley:PulleyViewController,
                               completion: PulleyAnimationCompletionBlock?) {
        if let top_drawer = _drawerStack.last {
            
            print("DRAWER: showTopDrawer \(top_drawer)")
            
            // get future position (could be drawer's current position)
            let pos = position ?? pulley.drawerPosition
            
            
            // close drawer
            pulley.setDrawerPosition(position: .closed, animated: true, completion: { (finished) in
                
                // change content
                pulley.setDrawerContentViewController(controller: top_drawer, animated: false, completion: { (finished2) in
                    
                    // reopen drawer
                    pulley.setDrawerPosition(position: pos, animated: true, completion: { (finished3) in
                        completion?(finished3)
                    })
                })
            })
        }
    }
}
