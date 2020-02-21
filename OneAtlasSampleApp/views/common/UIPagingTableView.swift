//
//  PagingTableView.swift
//  PagingTableView
//
//  Created by InJung Chung on 2017. 4. 16..
//  Copyright © 2017 InJung Chung. All rights reserved.
//

import UIKit

protocol UIPagingTableViewDelegate {
    func onPaginationDone(forPage page: Int, maxItems: Int, error: Error?)
    func onPaginationRequested(forPage page: Int)
}


class UIPagingTableView: UITableView {
    
    private var _loadingView: UIView!
    private var _indicator: UIActivityIndicatorView!
    internal var _page: Int = 0
    internal var _previousItemCount: Int = 0
    internal var _items:[Any] = []


    var pagingDelegate: UIPagingTableViewDelegate?

    
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.alpha = 0
        refreshControl?.addTarget(self, action: #selector(reset), for: .valueChanged)
    }
    
    
    @objc open func reset() {
        _items = []
        _page = 0
        _previousItemCount = 0
        showLoading()
        reloadData()
        pagingDelegate?.onPaginationRequested(forPage: 0)
    }
    
    
    private func paginate(_ tableView: UIPagingTableView, forIndexAt indexPath: IndexPath) {
        let itemCount = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: indexPath.section) ?? 0
        
        guard indexPath.row == itemCount - 1 else { return }
        guard _previousItemCount != itemCount else { return }
        
        _page += 1
        _previousItemCount = itemCount
        pagingDelegate?.onPaginationRequested(forPage: _page)
    }
    
    
    private func showLoading() {
        if _loadingView == nil {
            createLoadingView()
        }
        tableFooterView = _loadingView
    }
    
    
    func pagingCompletion(withItems items:[Any]?, maxItems:Int, error:Error?) {
        if let items = items,
            items.count > 0 {
            _items.append(contentsOf: items)
            reloadData()
        }
        refreshControl?.endRefreshing()
        tableFooterView = nil
        pagingDelegate?.onPaginationDone(forPage: _page, maxItems: maxItems, error: error)
    }
    
    
    private func createLoadingView() {
        _loadingView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        _indicator = UIActivityIndicatorView()
        _indicator.color = UIColor.lightGray
        _indicator.translatesAutoresizingMaskIntoConstraints = false
        _indicator.startAnimating()
        _loadingView.addSubview(_indicator)
        centerIndicator()
        tableFooterView = _loadingView
    }
    
    
    private func centerIndicator() {
        let xCenterConstraint = NSLayoutConstraint(
            item: _loadingView!, attribute: .centerX, relatedBy: .equal,
            toItem: _indicator, attribute: .centerX, multiplier: 1, constant: 0
        )
        _loadingView.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(
            item: _loadingView!, attribute: .centerY, relatedBy: .equal,
            toItem: _indicator, attribute: .centerY, multiplier: 1, constant: 0
        )
        _loadingView.addConstraint(yCenterConstraint)
    }
    
    
    override open func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        paginate(self, forIndexAt: indexPath)
        return super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}
