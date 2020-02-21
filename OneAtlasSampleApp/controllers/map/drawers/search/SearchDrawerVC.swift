//
//  SearchDrawerVC.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 01/09/19.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import Pulley
import MapboxGeocoder
import MapKit



protocol SearchDrawerPresenterContract {
    func loadSearchHistory()
    func addToSearchHistory(placemark:GeocodedPlacemark)
    func performGeocoding(query:String)
}


class SearchDrawerPresenter: SearchDrawerPresenterContract {
    private var _searchDrawerView:SearchDrawerViewContract
    
    init(searchDrawerView:SearchDrawerViewContract) {
        _searchDrawerView = searchDrawerView
    }
    
    func loadSearchHistory() {
        let placemarks = SearchHistoryManager.shared.getHistory()
        _searchDrawerView.reloadPlacemarks(placemarks: placemarks)
    }
    
    func addToSearchHistory(placemark: GeocodedPlacemark) {
        SearchHistoryManager.shared.addSearchPlacemark(placemark)
    }
    
    func performGeocoding(query:String) {
        GeoUtils.performGeocoding(query: query) { (placemarks:[GeocodedPlacemark]?, error:NSError?) in
            if let placemarks = placemarks {
                self._searchDrawerView.reloadPlacemarks(placemarks: placemarks)
            }
        }
    }
}


// =============================================================================
// MARK: - SearchDrawerVC
// =============================================================================
protocol SearchDrawerViewContract {
    func reloadPlacemarks(placemarks:[GeocodedPlacemark])
}


protocol SearchDrawerDelegate: BaseDrawerDelegate {
    func onSearchCancelClicked()
    func onSearchClearClicked()
    func onSearchPlacemarkSelected(placemark: GeocodedPlacemark)
    func onSearchButtonClicked(placemark: GeocodedPlacemark?)
}


class SearchDrawerVC: BaseTableDrawerVC {

    @IBOutlet var searchBar: UISearchBar!
    
    var maxSearchResults:UInt = 20
    var minSearchCharacters:UInt = 3
    var delegate:SearchDrawerDelegate?
    
    private var _animateBounce = true

    private var _presenter:SearchDrawerPresenterContract?
    private var _placemarks:[GeocodedPlacemark] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        _presenter = SearchDrawerPresenter(searchDrawerView: self)
        searchBar.delegate = self
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: AirbusColor.textDark.value]

        UISearchDrawerCell.registerNibIntoTable(tableView)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if _animateBounce {
            // The bounce here is optional, but it's done automatically after appearance as a demonstration.
            Timer.scheduledTimer(timeInterval: Config.animDurationSlow,
                                 target: self,
                                 selector: #selector(bounceDrawer),
                                 userInfo: nil,
                                 repeats: false)
        }
        
        if let text = searchBar.text,
            text.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                  at: .top,
                                  animated: false)
        }
        else {
            // reload history if search bar is empty
            _presenter?.loadSearchHistory()
        }
    }

    @objc fileprivate func bounceDrawer() {
        _animateBounce = false
        // We can 'bounce' the drawer to show users that the drawer needs their attention. There are optional parameters you can pass this method to control the bounce height and speed.
        pulleyViewController?.bounceDrawer()
    }
    
    override func onHeaderClicked(_ sender: Any) {
        // block default behaviour
    }
}


extension SearchDrawerVC: SearchDrawerViewContract {
    func reloadPlacemarks(placemarks: [GeocodedPlacemark]) {
        _placemarks = placemarks
        tableView.reloadData()
    }
}



// =============================================================================
// MARK: - UITableViewDataSource
// =============================================================================
extension SearchDrawerVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _placemarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UISearchDrawerCell.identifier(), for: indexPath) as! UISearchDrawerCell
        
        cell.textLabel?.text = _placemarks[indexPath.row].name
        cell.detailTextLabel?.text = _placemarks[indexPath.row].qualifiedName
        cell.backgroundColor = .clear
        return cell
    }
}


// =============================================================================
// MARK: - UITableViewDelegate
// =============================================================================
extension SearchDrawerVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let pl = _placemarks[indexPath.row]
        searchBar.text = pl.name
        _presenter?.addToSearchHistory(placemark: pl)
        delegate?.onSearchPlacemarkSelected(placemark: pl)
    }
}


// =============================================================================
// MARK: - UISearchBarDelegate
// =============================================================================
extension SearchDrawerVC: UISearchBarDelegate {

    // open drawer when user input begins
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        setPosition(.open)
        searchBar.showsCancelButton = true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        setPosition(.partiallyRevealed)
        delegate?.onSearchCancelClicked()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            // 'clear' button clicked or empty text because 'delete' key pressed
            _presenter?.loadSearchHistory()
            delegate?.onSearchClearClicked()
        }
        else if searchText.count >= minSearchCharacters {
            _presenter?.performGeocoding(query: searchText)
        }
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if _placemarks.count > 0 {
            SearchHistoryManager.shared.addSearchPlacemark(_placemarks[0])
            delegate?.onSearchButtonClicked(placemark: _placemarks[0])
        }
        else {
            delegate?.onSearchButtonClicked(placemark: nil)
        }
    }
}


// =============================================================================
// MARK: - PulleyDrawerViewControllerDelegate
// =============================================================================
extension SearchDrawerVC {
    override func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        super.drawerPositionDidChange(drawer: drawer, bottomSafeArea: bottomSafeArea)
        if drawer.drawerPosition != .open {
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
        }
        delegate?.onDrawerPositionDidChange(position: drawer.drawerPosition)
    }
}
