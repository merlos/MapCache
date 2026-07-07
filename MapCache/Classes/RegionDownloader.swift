//
//  TileDownloader.swift
//  MapCache
//
//  Created by merlos on 18/06/2019.
//

import Foundation
import MapKit

/// Hey! I need to download this area of the map.
/// No problemo.
///
/// This class allows you to download all the tiles of a region of the map.
///
/// Internally what it does is to iterate over every tile coordinate within the region and  request to a
/// mapCache to download it by calling its `loadTile` method.
///
/// In order to keep track of the downloaded data you can implement `ReguionDownloaderDelegate`.
///
/// Based on the value of `incrementInPercentageNotification` the delegate will be called.
///
/// Experimental
@objc public class RegionDownloader: NSObject {
    
    /// Approximation of the average number of bytes of a tile (used with 256x256 tiles).
    static let defaultAverageTileSizeBytes : UInt64 = 11664
    
    /// Region that will be downloaded.
    ///
    /// Initialized in the constructor
    public let region: TileCoordsRegion
    
    /// Cache that is going to be used for saving/loading the files.
    public let mapCache: MapCacheProtocol
    
    /// Total number of tiles to be downloaded.
    public var totalTilesToDownload: TileNumber {
        get {
            return region.count
        }
    }
    
    /// Number of tiles pending to be downloaded.
    public var pendingTilesToDownload: TileNumber {
        get {
            return region.count - downloadedTiles
        }
    }
    /// Maximum number of concurrent downloads. Default 30.
    /// If you set this to a low number, the download will take longer.
    /// If you set this to a high number, the download may fail due to too many concurrent downloads (e.g. 429 Too Many Requests).
    /// The downloader will automatically try after timeout.
    public var maxConcurrentDownloads: Int = 30

    /// Timeout for the download in seconds. Default 10 seconds.
    /// When the maximum number of concurrent downloads is reached, this is the time the downloader will wait for a download to finish before trying again.
    /// The downloader will automatically try after timeout.
    public var downloadTimeout: TimeInterval = 10.0
    
    /// The variable that actually keeps the count of the downloaded bytes.
    private var _downloadedBytes: UInt64 = 0
    
    


    /// Indicates that the download has been paused due to too many concurrent downloads. The downloader will automatically try after timeout.
    private var _stopped = false
    
    /// Total number of downloaded data bytes.
    public var downloadedBytes: UInt64 {
        get {
            return _downloadedBytes
        }
    }
    
    /// Returns the average
    ///
    /// This can be used to estimate the amount of bytes pending to be downloaded.
    public var averageTileSizeBytes: UInt64 {
        get {
            if downloadedTiles != 0 {
                return UInt64(_downloadedBytes / downloadedTiles)
            } else {
                return 0
            }
        }
    }
    
    /// Keeps the number of tiles already downloaded successfully or failed.
    @objc dynamic public var downloadedTiles: TileNumber {
        get {
            return _successfulTileDownloads + _failedTileDownloads
        }
    }
    
    /// Number of successfully downloaded tiles.
    private var _successfulTileDownloads : TileNumber = 0
    
    /// Keeps the number of tiles already downloaded.
    @objc dynamic public var successfulTileDownloads: TileNumber {
        get {
            return _successfulTileDownloads
        }
    }
    
    /// Keeps the number of tiles failes to be downloaded.
    /// Publicly accessible through failledTIleDownloads.
    private var _failedTileDownloads : TileNumber = 0
    
    /// Number of tiles to be downloaded
    @objc dynamic public var failedTileDownloads: TileNumber {
        get {
            return _failedTileDownloads
        }
    }
    
    /// Percentage to notify thought delegate.
    /// If set to >100 will only notify on finish download.
    /// If set to a percentage  smaller than `downloadedPercentage`, it will never notify.
    public var nextPercentageToNotify: Double = 5.0
    
    /// The downloader will notify the delegate every time this.
    /// For example if you set this to 5, it will notify when 5%, 10%, 15%, etc.
    /// Default value 5.
    public var incrementInPercentageNotification: Double = 5.0
    
    /// Last percentage notified to the deletage.
    var lastPercentageNotified: Double = 0.0
    
    
    /// Percentage of tiles pending to download.
    public var downloadedPercentage : Double {
        get {
            return 100.0 * Double(downloadedTiles) / Double(totalTilesToDownload)
        }
    }
    
    /// Delegate.
    public var delegate : RegionDownloaderDelegate?
    
    
    /// Queue to download the stuff.
    lazy var downloaderQueue : DispatchQueue = {
        let queueName = "MapCache.Downloader." + self.mapCache.config.cacheName
        //let downloaderQueue = DispatchQueue(label: queueName, attributes: [])
        let downloaderQueue = DispatchQueue(label: queueName, qos: .background, attributes: [])
        return downloaderQueue
    }()
    
    
    ///
    /// Initializes the downloader with the region and the MapCache.
    ///
    ///  - Parameter forRegion: the region to be downloaded.
    ///  - Parameter mapCache: the `MapCache` implementation used to download and store the downloaded data
    ///
    public init(forRegion region: TileCoordsRegion, mapCache: MapCacheProtocol) {
        self.region = region
        self.mapCache = mapCache
    }
    
    /// Resets downloader counters.
    public func resetCounters() {
        _stopped = false
        _downloadedBytes = 0
        _successfulTileDownloads = 0
        _failedTileDownloads = 0
        lastPercentageNotified = 0.0
        nextPercentageToNotify = incrementInPercentageNotification
    }
    
    /// Starts download.
    public func start() {
        //Downloads stuff
        resetCounters()
        downloaderQueue.async {
            self.delegate?.regionDownloader(self, willStartDownloading: self.totalTilesToDownload, region: self.region, mapCache: self.mapCache)
            /// Limit the number of tasks
            let semaphore = DispatchSemaphore(value: self.maxConcurrentDownloads)
            for range: TileRange in self.region.tileRanges() ?? [] {
                for tileCoords: TileCoords in range {
                    if self._stopped {
                        return
                    }
                    while semaphore.wait(timeout: DispatchTime(after: self.downloadTimeout)) == .timedOut {
                        if self._stopped {
                            return
                        }
                    }

                    ///Add to the download queue.
                    let mktileOverlayPath = MKTileOverlayPath(tileCoords: tileCoords)
                    self.mapCache.loadTile(at: mktileOverlayPath, result: { data, error in
                        semaphore.signal()
                        if error != nil {
                            Log.downloader.error("\(error?.localizedDescription ?? "Error downloading tile")")
                            self._failedTileDownloads += 1
                            self.delegate?.regionDownloader(self, didFailToDownloadTileAt: tileCoords, error: error!)
                            // TODO add to an array of tiles not downloaded
                            // so a retry can be performed
                        } else {
                            self._successfulTileDownloads += 1
                            self._downloadedBytes += UInt64(data?.count ?? 0)
                            self.delegate?.regionDownloader(self, didDownloadTileAt: tileCoords, dataSize: data?.count ?? 0)
                            Log.downloader.debug("Donwloaded zoom: \(tileCoords.zoom) (x:\(tileCoords.tileX),y:\(tileCoords.tileY), data.count: \(data?.count ?? 0)) \(self.downloadedTiles)/\(self.totalTilesToDownload) \(self.downloadedPercentage)%, bytes: \(self.downloadedBytes), average tile size: \(self.averageTileSizeBytes)")
                            
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
                            self.delegate?.regionDownloader(self, didFinishDownload: self.downloadedTiles)
                        }
                    })
                }
            }
        }
    }
    
    /// Stop download.
    public func stop() {
        _stopped = true
    }
    
    /// Returns an estimation of the total number of bytes the whole region may occupy.
    /// Again, it is an estimation.
    public func estimateRegionByteSize() -> UInt64 {
        return RegionDownloader.defaultAverageTileSizeBytes * self.region.count
    }
}

///
/// Extension to DispatchTime to allow creating a time after a given time interval.
/// - Parameter after: The time interval after which the new DispatchTime should be created.
/// 
public extension DispatchTime {

    init(after: TimeInterval) {
        Log.downloader.trace("DispatchTime.after: \(after) seconds")
        self.init(uptimeNanoseconds:DispatchTime.now().uptimeNanoseconds + UInt64(after * 1_000_000_000))
    }
}
