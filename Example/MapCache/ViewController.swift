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
    @IBOutlet weak var updateSizeButton: UIButton!
    @IBOutlet weak var clearCacheButton: UIButton!
    @IBOutlet weak var cacheSizeLabel: UILabel!
    
    var config: MapCacheConfig = MapCacheConfig(withTileUrlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        map.useMapCache(withConfig: config)
    }
    
    
    @IBAction func updateSize(_ sender: Any) {
        print("update cache size")
        let discCache = DiskCache(withName: config.cacheName)
        cacheSizeLabel.text = String(discCache.calculateSize())
    }
    
    
    @IBAction func clearCache(_ sender: Any) {
        print("clear cache")
        let discCache = DiskCache(withName: config.cacheName)
        discCache.removeAllData({
            self.cacheSizeLabel.text = String(discCache.calculateSize())
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return mapView.mapCacheRenderer(forOverlay: overlay)
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
