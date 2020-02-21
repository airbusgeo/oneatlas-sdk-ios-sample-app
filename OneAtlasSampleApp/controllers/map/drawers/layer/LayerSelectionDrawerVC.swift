//
//  LayerSelectionDrawerVC.swift
//  OneAtlasData
//
//  Created by Airbus DS on 20/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import Pulley
import MapEngineManager
import AirbusUI

fileprivate let CELL_PADDING = CGFloat(16.0)
fileprivate let CELL_MAX = EMapLayer.allCases.count


protocol LayerSelectionDrawerDelegate {
    func onLayerSelectionItemSelected(layer:EMapLayer, fromLayer:EMapLayer)
    func onLayerSelectionCancelClicked()
}


// ============================================================================
// MARK: - LayerSelectionDrawerVC
// ============================================================================
class LayerSelectionDrawerVC: BaseDrawerVC {

    @IBOutlet weak var cvLayers: UICollectionView!
    @IBOutlet weak var uvLayerHeader: UISearchDrawerHeader!
    

    private var _layers = [(title: String,
                            image: UIImage,
                            layerType: EMapLayer)]()
    private var _currentLayer = EMapLayer.street


    
    var delegate:LayerSelectionDrawerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _layers.append((Config.loc("mlayer_default"),
                        UIImage.init(named: "layer_default")!,
                        .street))
        _layers.append((Config.loc("mlayer_onelive"),
                        UIImage.init(named: "layer_basemap")!,
                        .basemap))
        _layers.append((Config.loc("mlayer_worlddem"),
                        UIImage.init(named: "layer_worlddem")!,
                        .worldDEM))

        cvLayers.allowsMultipleSelection = false
        cvLayers.register(UINib(nibName:UILayerCollectionCell.CELL_ID, bundle: nil),
                          forCellWithReuseIdentifier:UILayerCollectionCell.CELL_ID)
        
        uvLayerHeader.delegate = self
        uvLayerHeader.isLoading = false
        uvLayerHeader.showsFilter = false
        uvLayerHeader.title = Config.loc("MAP TYPE")
        uvLayerHeader.subtitle1 = Config.loc("Please select layer kind:")
        
    }
    
    override var _partiallyRevealedHeight:CGFloat {
        let cell_w = (CGFloat(view.bounds.width) - CGFloat(CELL_PADDING * CGFloat(CELL_MAX + 1))) / CGFloat(CELL_MAX)
        return uvLayerHeader.bounds.height + cell_w + (CELL_PADDING * 2)
    }
    
    
    override func supportedDrawerPositions() -> [PulleyPosition] {
        return [.closed, .partiallyRevealed]
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        // tell collection to select an item...
        let ip = IndexPath(row: 0, section: 0)
        cvLayers.selectItem(at: ip, animated: false, scrollPosition: .centeredHorizontally)
        
        // ...but force cell tint-ing anyway !
        if let cell:UILayerCollectionCell = cvLayers.cellForItem(at: ip) as? UILayerCollectionCell {
            cell.tint(color: Config.appColor)
        }
    }
}


// ============================================================================
// MARK: - UICollectionViewDelegate
// ============================================================================
extension LayerSelectionDrawerVC : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell:UILayerCollectionCell = collectionView.cellForItem(at: indexPath) as! UILayerCollectionCell
        cell.tint(color: Config.appColor)
        
        let prev_layer = _currentLayer
        let new_layer = _layers[indexPath.row].layerType;
        delegate?.onLayerSelectionItemSelected(layer: new_layer, fromLayer: prev_layer)
        _currentLayer = new_layer
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell:UILayerCollectionCell = collectionView.cellForItem(at: indexPath) as! UILayerCollectionCell
        cell.tint(color: AirbusColor.textLight.value)
    }
}


// ============================================================================
// MARK: - UICollectionViewDataSource
// ============================================================================
extension LayerSelectionDrawerVC : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:UILayerCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: UILayerCollectionCell.CELL_ID,
                                                                            for: indexPath) as! UILayerCollectionCell;
        
        cell.iconLabel.textColor = AirbusColor.textLight.value
        cell.iconLabel.text = _layers[indexPath.row].title
        cell.iconImage.image = _layers[indexPath.row].image
        cell.iconImage.tintColor = AirbusColor.textLight.value
    
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EMapLayer.allCases.count
    }
}


// ============================================================================
// MARK: - UICollectionViewDelegateFlowLayout
// ============================================================================
extension LayerSelectionDrawerVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let w = (CGFloat(collectionView.bounds.size.width) - CGFloat(CELL_PADDING * CGFloat(CELL_MAX + 1))) / CGFloat(CELL_MAX)
        
        return CGSize(width: w, height: w + 32)
    }
}


// ============================================================================
// MARK: - UISearchDrawerHeaderDelegate
// ============================================================================
extension LayerSelectionDrawerVC: UISearchDrawerHeaderDelegate {
    func onFilterClicked() {
    }
    
    func onCancelClicked() {
        delegate?.onLayerSelectionCancelClicked()
    }
}
