//
//  SplashVC.swift
//  OneAtlas iOS sample app
//
//  Created by Airbus DS on 13/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import OneAtlas
import Mapbox
import Pulley


// =============================================================================
// MARK: - SplashVC
// =============================================================================
class SplashVC: UIViewController {

    
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        aiLoading.hidesWhenStopped = true
        aiLoading.startAnimating()
        view.backgroundColor = Config.appColor
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // load API keys
        if let oneatlas_path = Bundle.main.path(forResource: "oneatlas", ofType: "apikey"),
            let mapbox_path = Bundle.main.path(forResource: "mapbox", ofType: "apikey") {
            do {
                let oneatlas_apikey = try String(contentsOfFile: oneatlas_path).trimmingCharacters(in: .whitespacesAndNewlines)
                let mapbox_apikey = try String(contentsOfFile: mapbox_path).trimmingCharacters(in: .whitespacesAndNewlines)
                performLogin(oneAtlasAPIKey: oneatlas_apikey, mapboxAPIKey: mapbox_apikey)
            } catch {
                showError(title: "Error",
                          message: "Cannot read the APIKey file contents. Please check the README file for more info.")
            }
        } else {
            showError(title: "Error",
                      message: "Cannot read the APIKey files. Please check the README file for more info.")
        }
    }
    
    
    private func performLogin(oneAtlasAPIKey: String,
                              mapboxAPIKey: String) {
        
        MGLAccountManager.accessToken = mapboxAPIKey
        GeoUtils.accessToken = mapboxAPIKey


        // register this app to receive auth token refresh events
        if let delegate = UIApplication.shared.delegate as? AuthServiceDelegate {
            OneAtlas.shared.authService?.registerDelegate(delegate)
        }


        // login with API Key
        OneAtlas.shared.authService?.login(with: oneAtlasAPIKey,
                                           clientID: .IDP,
                                           block: { (aError) in
            if let _ = aError {
                self.showError(title: "Error",
                               message: "Cannot login into OneAtlas. Please check your API key or network settings.")
            }
            else {
                // get the current user
                UserManager.refreshCurrentUser(completion: { (user, subscriptions, error) in
                    let guest = user?.isGuest ?? true || UserManager.activeDataSubscription == nil
                    if guest {
                        self.showError(title: "Error",
                                       message: "This user account seems deactivated.")
                    }
                    else {
                        
//                        if let sconf = MGLNetworkConfiguration.sharedManager.sessionConfiguration {
//                            sconf.httpAdditionalHeaders = OneAtlas.shared.authHeader
//                        }

                        
                        let map = MapVC(nibName: "MapVC", bundle: nil)
                        let drawer = SearchDrawerVC(nibName: "SearchDrawerVC", bundle: nil)
                        let pulley = PulleyViewController(contentViewController: map, drawerViewController: drawer)
                        self.navigationController?.pushViewController(pulley, animated: true)
                    }
                })
            }
        })
    }
    
    
    private func showError(title: String,
                           message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
