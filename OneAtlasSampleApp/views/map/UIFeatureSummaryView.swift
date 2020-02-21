//
//  UIFeatureSummaryView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 29/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import SDWebImage

import OneAtlas

class UIFeatureSummaryView: UIXibView {
    fileprivate static let THUMBNAIL_PLACEHOLDER = UIImage(named: "layer_default")

    
    @IBOutlet weak var ivThumbnail:UIImageView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var lbConstellation:UILabel!
    
    @IBOutlet weak var lbAngle:UILabel!
    @IBOutlet weak var ivAngle:UIImageView!
    @IBOutlet weak var lbCoverage:UILabel!
    @IBOutlet weak var ivCoverage:UIImageView!
    
    @IBOutlet weak var btBuy:UIButton!
    @IBOutlet weak var btBuyFake:UIButton!
    
    @IBOutlet weak var ivEye: UIImageView!
    
    
    var feature:OAFeature? {
        didSet {
            if let feature = feature as? OAProductFeature {
                
                if let date = feature.dateProperty(EProductFeaturePropertyAcquisitionDate) {
                    lbTitle.text = "\(DateUtils.niceDate(date: date, daysAgo: -1, utc: true)) "
                                   + Config.loc("g_at")
                                   + " \(DateUtils.niceTime(date: date, utc: true))"
                }
                else {
                    lbTitle.text = Config.loc("g_unknown_date")
                }
                                
                ivThumbnail.sd_setImage(with: feature.thumbnailURL,
                                        placeholderImage: UIFeatureSummaryView.THUMBNAIL_PLACEHOLDER,
                                        completed: nil)
                
                ivThumbnail.layer.masksToBounds = true
                lbConstellation.textColor = AirbusColor.textLight.value;
                lbAngle.textColor = AirbusColor.textLight.value;
                lbCoverage.textColor = AirbusColor.textLight.value;
                lbTitle.textColor = Config.appColor;
                
                ivAngle.tintColor = Config.appColor
                ivCoverage.tintColor = Config.appColor
                
                let cstr = feature.property(EProductFeaturePropertyConstellation) as! String
                let c = OAConstellation.constellation(cstr)
                lbConstellation.text = OAConstellation.constellationDisplayName(c)
                
                lbAngle.text = String(format: "%.01f°", feature.number(EProductFeaturePropertyIncidenceAngle)?.doubleValue ?? 0)
                lbCoverage.text = String(format: "%d%%", Int(feature.number(EProductFeaturePropertyCloudCover)?.doubleValue ?? 0))
            }
            else {
                // TODO: handle more feature types...
            }
        }
    }
}
