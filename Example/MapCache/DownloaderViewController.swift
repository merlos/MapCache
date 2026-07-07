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
    
    /// Label that displays the download progress.
    var statusLabel: UILabel!
    
    /// Pause button to stop the download.
    var pauseButton: UIButton!
    
    /// Current downloader instance.
    var regionDownloader: RegionDownloader?
    
    /// region to download.
    var region : TileCoordsRegion?
    
    /// Zoom range to download
    var zoomRange : ZoomRange?
    
    /// Cache config that uses open street map.
    var config: MapCacheConfig = MapCacheConfig(withUrlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")
    
    
    var mapCache : MapCache?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        
        // (optional) 
        // By default the cache folder is set to the caches folder of the application (which can be deleted by the OS if there is low disk space). 
        // You can change it to any other folder.
        // For example, you can set it to the application support folder, which is not deleted by the OS.
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        config.baseURL = appSupport
        print("*** Cache base folder: \(config.baseURL?.path ?? "Not set")")
        
        // (optional) You can set the name of the cache  
        // config.cacheName = "Downloads" # default "MapCache" Useful if you have different caches for different purposes.

        mapCache = MapCache(withConfig: config)
        _ = mapView.useCache(mapCache!)
        

        print("*** Actual path where the files are stored: \(mapCache?.diskCache.path ?? "No disk cache path")")
       

        // Initialize region from current map view and slider default zoom.
        region = TileCoordsRegion(topLeftLatitude: 10.0, topLeftLongitude: 10.0, bottomRightLatitude: 20.0, bottomRightLongitude: 20.0, minZoom: 1, maxZoom: 9)
        slider.value = 10
        updateRegion()
        
        // Setup status label for download progress
        statusLabel = UILabel(frame: CGRect(x: 0, y: progressView.frame.minY - 20, width: view.frame.width, height: 18))
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 13)
        statusLabel.textColor = .darkGray
        statusLabel.text = ""
        view.addSubview(statusLabel)
        
        // Setup pause button below the slider, right-aligned
        let sliderFrame = view.convert(slider.frame, from: slider.superview)
        pauseButton = UIButton(type: .system)
        pauseButton.frame = CGRect(x: view.frame.width - 100, y: sliderFrame.maxY - 50, width: 60, height: 28)
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.backgroundColor = .systemBlue
        pauseButton.setTitleColor(.white, for: .normal)
        pauseButton.layer.cornerRadius = 6
        pauseButton.titleLabel?.font = .systemFont(ofSize: 13)
        pauseButton.addTarget(self, action: #selector(togglePause), for: .touchUpInside)
        pauseButton.isHidden = true
        view.addSubview(pauseButton)
    }
    
    
    /// Activated when download region button is pressed
    @IBAction func downloadRegion(_ sender: Any) {
        print("Download Region Pressed!")

        let downloader = RegionDownloader(forRegion: region!, mapCache: mapCache!)
        downloader.delegate = self
        regionDownloader = downloader
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.isHidden = false
        downloader.start()
    }

    /// Toggles between pause and resume.
    @objc func togglePause() {
        guard let downloader = regionDownloader else { return }
        if pauseButton.title(for: .normal) == "Pause" {
            downloader.stop()
            pauseButton.setTitle("Resume", for: .normal)
            statusLabel.text = "Download paused"
        } else {
            downloader.resume()
            pauseButton.setTitle("Pause", for: .normal)
            statusLabel.text = "Resuming download..."
        }
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
        
       // print("New Region: topLeft: (\(region?.topLeft.latitude),\(region?.topLeft.longitude)) bottomRight: (\(region?.bottomRight.latitude),\(region?.bottomRight.longitude)) zoom: \(region?.zoomRange.min)->\(region?.zoomRange.max)")
        // Update label with info
        label.text = "Download \(region?.count ?? 0) tiles | zoom: \(region?.zoomRange.min ?? 0)->\(region?.zoomRange.max ?? 0)"
    }

}

extension DownloaderViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return mapView.mapCacheRenderer(forOverlay: overlay)
    }
    
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
        DispatchQueue.main.async {
            self.progressView.progress = 1.0
            self.statusLabel.text = "Downloaded: \(regionDownloader.successfulTileDownloads)/\(regionDownloader.totalTilesToDownload) tiles | Failed: \(regionDownloader.failedTileDownloads)"
            self.pauseButton.isHidden = true
        }
    }

    func regionDownloader(_ regionDownloader: RegionDownloader, willStartDownloading totalTiles: TileNumber, region: TileCoordsRegion, mapCache: MapCacheProtocol) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Starting download of \(totalTiles) tiles..."
        }
    }

    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadTileAt tileCoords: TileCoords, dataSize: Int) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Downloaded: \(regionDownloader.successfulTileDownloads)/\(regionDownloader.totalTilesToDownload) tiles | Failed: \(regionDownloader.failedTileDownloads)"
        }
    }

    func regionDownloader(_ regionDownloader: RegionDownloader, didFailToDownloadTileAt tileCoords: TileCoords, error: Error) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Downloaded: \(regionDownloader.successfulTileDownloads)/\(regionDownloader.totalTilesToDownload) tiles | Failed: \(regionDownloader.failedTileDownloads)"
        }
    }
}
