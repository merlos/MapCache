//
//  DownloaderViewController.swift
//  MapCache_Example
//
//  Created by merlos on 02/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import MapKit
import MapCache

class DownloaderViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var downloadButton: UIButton!
    
    /// region to download.
    //
    var region : TileCoordsRegion?
    /// Zoom range to download
    var zoomRange : ZoomRange?
        
        
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        //Initialize the region with any random value.
        region = TileCoordsRegion(topLeftLatitude: 10.0, topLeftLongitude: 10.0, bottomRightLatitude: 20.0, bottomRightLongitude: 20.0, minZoom: 1, maxZoom: 9)
        
    }
    
    
    /// Activated when download region button is pressed
    @IBAction func downloadRegion(_ sender: Any) {
        print("Download Region Pressed!")
        
        let config = MapCacheConfig()
        let mapCache = MapCache(withConfig: config)
        let downloader = RegionDownloader(forRegion: region!, mapCache: mapCache)
        let delegate = self
        downloader.delegate = delegate
        downloader.start()
        
    }
    /// Slider changed its value
    @IBAction func sliderValueChanged(_ sender: Any) {
        print("Slider value Changed \(Zoom(slider.value))" )
        updateRegion()
    }
    
    /// closes this view controller
    @IBAction func closeViewController(_ sender: Any) {
        dismiss(animated: true  )
    }
    
    func updateRegion() {
        // get zoom levels
        let minZoom: Zoom = 1
        let maxZoom: Zoom = Zoom(slider.value)
        
        // get Lat and lon
        let center = mapView.region.center
        let regionSpan = mapView.region.span
        let topLeft = TileCoords(latitude: center.latitude  + (regionSpan.latitudeDelta  / 2.0),
                                 longitude: center.longitude - (regionSpan.longitudeDelta / 2.0),
                                 zoom: minZoom)!
        let bottomRight = TileCoords(latitude: center.latitude  - (regionSpan.latitudeDelta  / 2.0),
                                     longitude: center.longitude + (regionSpan.longitudeDelta / 2.0),
                                     zoom: maxZoom)!
        //
        region?.topLeft = topLeft
        region?.bottomRight = bottomRight
        
        print("New Region: topLeft: (\(region?.topLeft.latitude),\(region?.topLeft.longitude)) bottomRight: (\(region?.bottomRight.latitude),\(region?.bottomRight.longitude)) zoom: \(region?.zoomRange.min)->\(region?.zoomRange.max)")
        // Update label with info
        label.text = "Download \(region?.count) tiles\n  zoom: \(region?.zoomRange.min)->\(region?.zoomRange.max)"
    }

}

extension DownloaderViewController : MKMapViewDelegate {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print("current ZoomLevel: \(mapView.zoomLevel)")
        updateRegion()
        
    }
}

extension DownloaderViewController : RegionDownloaderDelegate {
    
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double) {
         DispatchQueue.main.async { 
            self.progressView.progress = Float(percentage / 100.0)
        }
        
    }
    
    func regionDownloader(_ regionDownloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber) {
        self.progressView.progress = 1.0
        
    }
    
    
}
