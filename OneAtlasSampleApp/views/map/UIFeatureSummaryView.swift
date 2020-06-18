//
//  UIFeatureSummaryView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 29/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
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
    
    
    var feature: Feature? {
        didSet {
            if let feature = feature as? ProductFeature {
                
                if let date = feature.properties[.acquisitionDate] as? Date {
                    lbTitle.text = "\(DateUtils.niceDate(date: date, daysAgo: -1, utc: true)) "
                                   + Config.loc("g_at")
                                   + " \(DateUtils.niceTime(date: date, utc: true))"
                }
                else {
                    lbTitle.text = Config.loc("g_unknown_date")
                }

                ivThumbnail.image = UIFeatureSummaryView.THUMBNAIL_PLACEHOLDER
                feature.downloadThumbnail() { (image, error) in
                    if let image = image {
                        self.ivThumbnail.image = image
                    }
                }

                ivThumbnail.layer.masksToBounds = true
                lbConstellation.textColor = Color.textLight.value;
                lbAngle.textColor = Color.textLight.value;
                lbCoverage.textColor = Color.textLight.value;
                lbTitle.textColor = Config.appColor;

                ivAngle.tintColor = Config.appColor
                ivCoverage.tintColor = Config.appColor

                if let cstr = feature.properties[.constellation] as? String {
                    let c = EConstellation(rawValue: cstr) ?? .unknown
                    lbConstellation.text = c.displayName
                }

                lbAngle.text = String(format: "%.01f°", feature.properties[.incidenceAngle] as? Double ?? 0)
                lbCoverage.text = String(format: "%d%%", Int(feature.properties[.cloudCover] as? Double ?? 0))
            }
            else {
                // TODO: handle more feature types...
            }
        }
    }
}
