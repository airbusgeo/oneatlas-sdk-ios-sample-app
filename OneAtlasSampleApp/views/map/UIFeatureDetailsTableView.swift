//
//  UIFeatureDetailsTableView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 29/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit

import OneAtlas


protocol UIFeatureDetailsTableViewDelegate {
    
}


typealias FeatureProperty = (title:String, value:String, icon:String)


class UIFeatureDetailsTableView: UITableView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        delegate = self
        
        backgroundColor = .clear
        separatorStyle = .none
        allowsSelection = false
    }
    
    
    var workspaceKind:EWorkspaceKind?

    var feature:Feature? {
        didSet {
            refresh()
        }
    }
    
    private var _productionProps:[FeatureProperty] = Array()
    private var _archiveProps:[FeatureProperty] = Array()
    
    // contains some of the arrays above, depending on feature source type
    private var _sections:[(sectionType:String, properties:[FeatureProperty])] = Array()

    
    private func refresh() {
        _productionProps.removeAll()
        _archiveProps.removeAll()
        _sections.removeAll()

        buildPropertyList()
       
        switch workspaceKind {
        case .myImages?:
            _sections.append((NSLocalizedString("fp_archiveinfo", comment: ""), _archiveProps))
            _sections.append((NSLocalizedString("fp_productioninfo", comment: ""), _productionProps))
            break
        case .livingLibrary?:
            _sections.append((NSLocalizedString("fp_archiveinfo", comment: ""), _archiveProps))
            break
        default:
            break
        }
        reloadData()
    }
    
    
    private func buildPropertyList() {
        
        if feature is ProductFeature {
            
            // ARCHIVE
            _archiveProps.append((title:Config.loc("fp_sourceIdentifier"),
                                  value:valueFromProperty(.sourceID, unit:""),
                                  icon:"baseline_image_black_18pt"))
            _archiveProps.append((title:Config.loc("fp_acquisitionDate"),
                                  value:valueFromProperty(.acquisitionDate, unit:""),
                                  icon:"baseline_calendar_today_black_18pt"))
            _archiveProps.append((title:Config.loc("fp_azimuthAngle"),
                                  value:valueFromProperty(.azimuthAngle, unit:"°"),
                                  icon:"icon_angle"))
            _archiveProps.append((title:Config.loc("fp_cloudCover"),
                                  value:valueFromProperty(.cloudCover, unit:"%"),
                                  icon:"icon_cloud"))
            _archiveProps.append((title:Config.loc("fp_illuminationAzimuthAngle"),
                                  value:valueFromProperty(.illuminationAzimuthAngle, unit:"°"),
                                  icon:"icon_angle"))
            _archiveProps.append((title:Config.loc("fp_illuminationElevationAngle"),
                                  value:valueFromProperty(.illuminationElevationAngle, unit:"°"),
                                  icon:"icon_angle"))
            _archiveProps.append((title:Config.loc("fp_incidenceAngleAlongTrack"),
                                  value:valueFromProperty(.incidenceAngleAlongTrack, unit:"v"),
                                  icon:"icon_angle"))
            _archiveProps.append((title:Config.loc("fp_incidenceAngleAcrossTrack"),
                                  value:valueFromProperty(.incidenceAngleAcrossTrack, unit:"°"),
                                  icon:"icon_angle"))
            
            
            // PRODUCTION
            _productionProps.append((title:Config.loc("fp_processingLevel"),
                                     value:valueFromProperty(.processingLevel, unit:""),
                                     icon:"icon_gear"))
            _productionProps.append((title:Config.loc("fp_sensorType"),
                                     value:valueFromProperty(.sensorType, unit:""),
                                     icon:"baseline_satellite_black_18pt"))
            _productionProps.append((title:Config.loc("fp_spectralRange"),
                                     value:valueFromProperty(.spectralRange, unit:""),
                                     icon:"baseline_remove_red_eye_black_18pt"))
            _productionProps.append((title:Config.loc("fp_productType"),
                                     value:valueFromProperty(.productType, unit:""),
                                     icon:"icon_up"))
        }
        else {
            // TODO: handle other features...
        }
    }
    
    
    private func valueFromProperty(_ prop:EProductFeatureProperty,
                                   unit:String) -> String {
        var disp_val = ""
        if let productFeature = feature as? ProductFeature,
            let val = productFeature.properties[prop] {

            if let str = val as? String {
                disp_val = str
            }
            else if let num = val as? Double {
                disp_val = String(format: "%.02f", num)
            }
            else if let date = val as? Date {
                disp_val = DateUtils.niceDate(date: date, daysAgo: -1, utc: true)
            }
        }
        return disp_val
    }
}


// =============================================================================
// MARK: - UITableViewDelegate
// =============================================================================
extension UIFeatureDetailsTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIFeaturePropertyCell.DEFAULT_HEIGHT
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UICardFooterView.DEFAULT_HEIGHT
    }
    
    
    func tableView(_ tab: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v = UIView.init(frame: CGRect(x: 0, y: 0,
                                          width: bounds.width,
                                          height: tableView(tab, heightForHeaderInSection: section)))
        v.backgroundColor = .clear
        
        let lb = UILabel.init(frame: v.bounds)
        lb.textAlignment = .center
        lb.text = _sections[section].sectionType
        lb.textColor = Config.appColor
        lb.font = AirbusFont.regularBold.value
        
        v.addSubview(lb)
        return v
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



// =============================================================================
// MARK: - UITableViewDataSource
// =============================================================================
extension UIFeatureDetailsTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sections[section].properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIFeaturePropertyCell.identifier(), for: indexPath) as! UIFeaturePropertyCell

        let properties = _sections[indexPath.section].properties
        let property = properties[indexPath.row]
        cell.property = property
        return cell
    }
}
