//
//  TileDownloader.swift
//  MapCache
//
//  Created by merlos on 18/06/2019.
//

import Foundation
import MapKit

/// Hey! I need to download this area
/// No problemo.
class RegionDownloader {
    /// Average number of bytes of a tile
    static let defaultAverageTileSizeBytes : UInt64 = 11664
    
    /// region that will be downloaded
    let region: TileCoordsRegion
    
    /// Cache that is going to be used for saving/loading the files.
    let mapCache: MapCacheProtocol
    
    /// Total number of tiles to be downloaded
    var totalTilesToDownload: TileNumber {
        get {
            return region.count
        }
    }
    
    /// Number of tiles pending to be downloaded
    var pendingTilesToDownload: TileNumber {
        get {
            return region.count - _downloadedTiles
        }
    }
    
    
    private var _downloadedBytes: UInt64 = 0
    
    /// Total number of downloaded data bytes
    var downloadedBytes: UInt64 {
        get {
            return _downloadedBytes
        }
    }
    
    /// Returns the average
    ///
    /// This can be used to estimate the
    var averageTileSizeBytes: UInt64 {
        get {
            if _downloadedTiles != 0 {
                return UInt64(_downloadedBytes / _downloadedTiles)
            } else {
                return 0
            }
        }
    }
    /// It actually keeps the number of downloaded tiles in the current session.
    /// It is only modified internally
    private var _downloadedTiles : TileNumber = 0
    
    /// Keeps the number of tiles already downloaded successfully or failed.
    @objc dynamic var downloadedTiles: TileNumber {
        get {
            return _downloadedTiles
        }
    }
    
    ///
    private var _successfulTileDownloads : TileNumber = 0
    
    /// Keeps the number of tiles already downloaded.
    @objc dynamic var successfulTileDownloads: TileNumber {
        get {
            return _successfulTileDownloads
        }
    }
    
    /// Keeps the number of tiles failes to be downloaded
    /// Publicly accessible through failledTIleDownloads
    private var _failedTileDownloads : TileNumber = 0
    
    /// Number of tiles to be downloaded
    @objc dynamic var failedTileDownloads: TileNumber {
        get {
            return _failedTileDownloads
        }
    }
    
    /// Percentage to notify thought delegate
    /// If set to >100 will only notify on finish download
    /// If set to a percentage < `downloadedPercentage`, will never notify.
    var nextPercentageToNotify: Double = 5.0
    
    /// The downloader will notify the delegate every time this
    /// For example if you set this to 5, it will notify when 5%, 10%, 15%, etc...
    /// default value 5.
    var incrementInPercentageNotification: Double = 5.0
    
    /// Last notified
    var lastPercentageNotified: Double = 0.0
    
    
    /// Percentage of tiles pending to download.
    var downloadedPercentage : Double {
        get {
            return 100.0 * Double(_downloadedTiles / totalTilesToDownload)
        }
    }
    
    /// Delegate
    var delegate : RegionDownloaderDelegate?
    
    
    /// Queue to download stuff.
    lazy var downloaderQueue : DispatchQueue = {
        let queueName = "MapCache.Downloader." + self.mapCache.config.cacheName
        //let downloaderQueue = DispatchQueue(label: queueName, attributes: [])
        let downloaderQueue = DispatchQueue(label: queueName, qos: .background, attributes: [])
        return downloaderQueue
    }()
    
    
    ///
    /// initializes the downloader with the region and the MapCache
    ///
    init(forRegion region: TileCoordsRegion, mapCache: MapCache) {
        self.region = region
        self.mapCache = mapCache
    }
    
    /// Starts download
    func start() {
        //Downloads stuff
        downloaderQueue.async {
            for range: TileRange in self.region.tileRanges() ?? [] {
                for tileCoords: TileCoords in range {
                    ///Add to the download queue.
                    let mktileOverlayPath = MKTileOverlayPath(tileCoords: tileCoords)
                    self.mapCache.loadTile(at: mktileOverlayPath, result: {data,error in
                        if error != nil {
                            print(error?.localizedDescription ?? "Error downloading tile")
                            self._failedTileDownloads += 1
                        } else {
                            print("RegionDownloader:: Donwloaded zoom: \(tileCoords.zoom) (x:\(tileCoords.tileX),y:\(tileCoords.tileY))")
                            self._successfulTileDownloads += 1
                        }
                        //check if needs to notify duet to percentage
                        if self.downloadedPercentage > self.nextPercentageToNotify {
                            //Update status variables
                            self.lastPercentageNotified = self.nextPercentageToNotify
                            self.nextPercentageToNotify += self.incrementInPercentageNotification
                            //call the delegate
                            self.delegate?.regionDownloader(self, didDownloadPercentage: self.downloadedPercentage)
                        }
                        //Did we finish download
                        if self.downloadedTiles == self.totalTilesToDownload {
                            self.delegate?.regionDownloader(self, didDownloadFinish: self.downloadedTiles)
                        }
                    })
                }
            }
        }
    }
    
    /// Returns an estimation of the total number of bytes the whole region may occupy.
    /// It is an estimation.
    func estimateRegionByteSize() -> UInt64 {
        return RegionDownloader.defaultAverageTileSizeBytes * self.region.count
    }
    
    
}
