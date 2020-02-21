//
//  SearchResultsFilterVC.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 16/07/2019.
//  Copyright © 2019 Airbus. All rights reserved.
//

import UIKit
import RMDateSelectionViewController



struct SearchFilterCriteria {
    var maxDate: Date?
    var minDate: Date?
    var resolutionIndex: Int = 0
    var maxCloud: Int = Config.filterMaxCloud
    var maxAngle: Int = Config.filterMaxAngle
    
    var isDefault: Bool {
        return maxDate == nil &&
                minDate == nil &&
                resolutionIndex == 0 &&
                maxCloud == Config.filterMaxCloud &&
                maxAngle == Config.filterMaxAngle
    }
}


// =============================================================================
// MARK: - SearchResultsFilterDelegate
// =============================================================================
protocol SearchResultsFilterDelegate {
    func onSearchResultsFilterChanged(_ aSearchResultsFilter:SearchResultsFilterVC,
                                      criteria aCriteria:SearchFilterCriteria) -> Void
}


// =============================================================================
// MARK: - SearchResultsFilterVC
// =============================================================================
class SearchResultsFilterVC: BaseFilterVC {
    
    var delegate:SearchResultsFilterDelegate?
    var criteria:SearchFilterCriteria = SearchFilterCriteria()
    
    private var _isDefault = true

    @IBOutlet weak var btDateMin: UIButton!
    @IBOutlet weak var btDateMax: UIButton!
    @IBOutlet weak var scResolution: UISegmentedControl!
    @IBOutlet weak var slCloud: UISlider!
    @IBOutlet weak var slAngle: UISlider!
    @IBOutlet weak var lbCloud: UILabel!
    @IBOutlet weak var lbAngle: UILabel!
    @IBOutlet weak var ivArrow: UIImageView!
    @IBOutlet weak var ivDate: UIImageView!
    @IBOutlet weak var ivCloud: UIImageView!
    @IBOutlet weak var ivAngle: UIImageView!
    @IBOutlet weak var ivResolution: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWithTitle(Config.loc("bsfilter_title"), color: Config.appColor, delegate: self)
        
        if #available(iOS 13.0, *) {
            // Oh, you want to customize UISegmentedControl in iOS13 ?
            // https://medium.com/flawless-app-stories/ios-13-uisegmentedcontrol-3-important-changes-d3a94fdd6763
            scResolution.selectedSegmentTintColor = Config.appColor
            scResolution.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : AirbusColor.textWhite.value], for: .selected)
            scResolution.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : AirbusColor.textDark.value], for: .normal)
        } else {
            scResolution.tintColor = Config.appColor
        }

        slCloud.tintColor = Config.appColor
        slAngle.tintColor = Config.appColor
        
        btDateMin.layer.cornerRadius = btDateMin.bounds.height / 2
        btDateMin.tintColor = Config.appColor
        
        btDateMax.layer.cornerRadius = btDateMax.bounds.height / 2
        btDateMax.tintColor = Config.appColor

        ivArrow.tintColor = Config.appColor
        ivCloud.tintColor = Config.appColor
        ivAngle.tintColor = Config.appColor
        ivDate.tintColor = Config.appColor
        ivResolution.tintColor = Config.appColor
    
        onRefreshRequested()
    }
    
    
    @IBAction func onResolutionIndexChanged(_ sender: Any) {
        criteria.resolutionIndex = scResolution.selectedSegmentIndex
    }
    
    
    @IBAction func onDateMinClicked(_ sender: Any) {
        showDatePicker(sender, isMin: true)
    }
    
    
    @IBAction func onDateMaxClicked(_ sender: Any) {
        showDatePicker(sender, isMin: false)
    }
    
    
    @IBAction func onMaxCloudValueChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            criteria.maxCloud = Int(slider.value)
            lbCloud.text = Config.loc("bsfilter_max_cloud").replacingOccurrences(of: "$__percent__", with: String(Int(slider.value)))
        }
    }
    
    
    @IBAction func onMaxAngleValueChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            criteria.maxAngle = Int(slider.value)
            lbAngle.text = Config.loc("bsfilter_max_angle").replacingOccurrences(of: "$__degrees__", with: String(Int(slider.value)))
        }
    }
    
    
    private func showDatePicker(_ sender: Any, isMin:Bool) {
        
        let select = RMAction<UIDatePicker>.init(title: Config.loc("bsfilter_select"), style: .done) { (controller:RMActionController) in
            if let bt = sender as? UIButton {
                if(isMin) {
                    self.criteria.minDate = controller.contentView.date
                }
                else {
                    self.criteria.maxDate = controller.contentView.date
                }
                self.setDate(date: controller.contentView.date, onButton: bt)
            }
        }
        if let bt = select?.view as? UIButton {
            bt.setTitleColor(Config.appColor, for: .normal)
        }

        
        let clear = RMAction<UIDatePicker>.init(title: Config.loc("bsfilter_clear"), style: .destructive) { (controller:RMActionController) in
            if let bt = sender as? UIButton {
                if(isMin) {
                    self.criteria.minDate = nil
                }
                else {
                    self.criteria.maxDate = nil
                }
                self.setDate(date: nil, onButton: bt)
            }
        }
        
        
        if let ctl = RMDateSelectionViewController.init(style: .white,
                                                        title: isMin ? Config.loc("bsfilter_min_date") :
                                                                    Config.loc("bsfilter_max_date"),
                                                        message: nil,
                                                        select: select,
                                                        andCancel: clear) {
            ctl.datePicker.datePickerMode = .date
            present(ctl, animated: true, completion: nil)
        }
    }
    
    
    private func setDate(date:Date?, onButton button:UIButton) {
        if let d = date {
            button.setTitle(DateUtils.niceDate(date: d, daysAgo: -1, utc: true), for: .normal)
        }
        else {
            button.setTitle(Config.loc("bsfilter_no_date"), for: .normal)
        }
    }
}


// =============================================================================
// MARK: - BaseFilterDelegate
// =============================================================================
extension SearchResultsFilterVC: BaseFilterDelegate {
    
    func onResetClicked() {
        criteria = SearchFilterCriteria()
        onRefreshRequested()
    }
    
    
    func onApplyClicked() {
        delegate?.onSearchResultsFilterChanged(self,
                                               criteria: criteria)
    }
    
    
    func onRefreshRequested() {
        scResolution.selectedSegmentIndex = criteria.resolutionIndex
        slCloud.value = Float(criteria.maxCloud)
        slAngle.value = Float(criteria.maxAngle)
        setDate(date: criteria.minDate, onButton: btDateMin)
        setDate(date: criteria.maxDate, onButton: btDateMax)
        onMaxAngleValueChanged(slAngle as Any)
        onMaxCloudValueChanged(slCloud as Any)
    }
}
