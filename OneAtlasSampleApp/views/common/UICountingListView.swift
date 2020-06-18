//
//  UICountingListView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 17/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit



class UICountingListView: UIXibView {
    
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var tvResults: UIPagingTableView!
    
    internal var _total = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tvResults.separatorStyle = .none
        tvResults.backgroundColor = .clear
        
        lbCount.text = ""
        lbCount.textColor = Color.textLight.value
        lbCount.font = AirbusFont.tiny.value
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // force apply xib-defined constraints
        contentView.frame = bounds
    }
    
    
    func showLoading() {
        lbCount.text = Config.loc("g_loading")
    }
    
    
    func showCount(_ count:Int, error:Error?) {
        if let _ = error {
            lbCount.text = Config.loc("g_error_occured")
        }
        else {
            let none = Config.loc("g_no_results")
            let results = Config.loc("g_x_results_found")
                          .replacingOccurrences(of: "$__res__", with: String(count))
                          .replacingOccurrences(of: "$__plu__", with: count > 1 ? "s" : "")
            lbCount.text = count > 0 ? results : none
        }
    }
    
    
    func addRefreshControl() {
        tvResults.addRefreshControl()
    }
}
