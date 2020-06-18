//
//  UIUserAOITableCell.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 14/10/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import CoreLocation


class UIUserAOITableCell: UIAutoRegisterTableCell {

    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbCoords: UILabel!
    @IBOutlet weak var lbName: UILabel!
    
    override class var DEFAULT_HEIGHT: CGFloat {
        return 64
    }
    
    var aoi: UserAOI? {
        didSet {
            if let aoi = aoi {
                let p = aoi.centroid
                lbName.text = aoi.name
                
                // reverse geocode
                let coord_str = "(" + GeoUtils.coordinateString(coord: CLLocationCoordinate2D.from(point: p)) + ")"
                lbCoords.text = coord_str
                
                GeoUtils.performReverseGeocoding(coord: CLLocationCoordinate2D.from(point: p)) { (placemark, error) in
                    DispatchQueue.main.async {
                        if let placemark = placemark {
                            self.lbCoords.text = placemark.name + " " + coord_str
                        }
                    }
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ivIcon.tintColor = Config.appColor
        lbName.textColor = Config.appColor
        lbCoords.textColor = Color.textLight.value
        lbName.font = AirbusFont.regularBold.value
        lbCoords.font = AirbusFont.tiny.value
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
