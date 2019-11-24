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
    
    @IBOutlet weak var downloadRegionButton: UIButton!
    
    /// Map Cache config contains all the config options.
    /// Initialize it before seting up the cache
    var config: MapCacheConfig = MapCacheConfig(withUrlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")
    
    /// Da Map Cache
    var mapCache: MapCache?
    
    /// We can initialize our cache here.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // See below the extension of the delegate
        // You need to tell MKMapView to render the overlay
        // func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
        map.delegate = self
        
        // initialize the cache with our config
        mapCache = MapCache(withConfig: config)
        // See documentation to know more about config options
        
        
        // We tell our MKMapView to use the cache
        // useCache(:) is part of MapCache extension.
        _ = map.useCache(mapCache!)
    }
    
    @IBAction func updateSize(_ sender: Any) {
        print("update cache size")
        cacheSizeLabel.text = String(mapCache!.calculateDiskSize())
    }
    
    @IBAction func clearCache(_ sender: Any) {
        print("clear cache")
        mapCache!.clear() { 
            self.cacheSizeLabel.text = String(self.mapCache!.calculateDiskSize())
        }
    }
    
    @IBAction func downloadRegion(_ sender: Any) {
        // Opens a new view controller
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//
// It is important to override this method of the MKMapViewDelegate
//
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
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print("ZoomLevel: \(mapView.zoomLevel)")
    }
}
