//
//  ViewController.swift
//  MapCache
//
//  Created by merlos on 05/12/2019.
//  Copyright (c) 2019 merlos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MapCache

class ViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set delegate
        map.delegate = self
        
        //Request permissions
        //Config
        let config = MapCacheConfig(withTileUrlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")
        
        
        let tileServerOverlay = CachedTileOverlay(mapCacheConfig: config)
        tileServerOverlay.canReplaceMapContent = true
        map.insert(tileServerOverlay, at: 0, level: .aboveLabels)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        return MKOverlayRenderer()
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Hello
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Hello 
    }
}
