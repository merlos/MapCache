//
//  RegionDownloaderDelegate.swift
//  MapCache
//
//  Created by merlos on 18/06/2019.
//

import Foundation

///
/// `RegionDownloaderDelegate` provides callbacks for monitoring the progress of a tile region download.
///
/// Conform to this protocol to receive notifications about download progress, individual tile results,
/// and lifecycle events. All methods have default empty implementations provided via a protocol extension,
/// making each callback optional — implement only the ones you need.
///
/// # Usage Example
///
/// ```swift
/// class MyViewController: UIViewController, RegionDownloaderDelegate {
///
///     func startDownload() {
///         let downloader = RegionDownloader(forRegion: region, mapCache: cache)
///         downloader.delegate = self
///         downloader.start()
///     }
///
///     // Update a progress bar on percentage changes.
///     func regionDownloader(_ downloader: RegionDownloader, didDownloadPercentage percentage: Double) {
///         DispatchQueue.main.async {
///             self.progressView.progress = Float(percentage / 100.0)
///         }
///     }
///
///     // Show final counts when done.
///     func regionDownloader(_ downloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber) {
///         DispatchQueue.main.async {
///             self.label.text = "Done: \(tilesDownloaded) tiles"
///         }
///     }
/// }
/// ```
///
public protocol RegionDownloaderDelegate: AnyObject {

    /// Called each time the overall download percentage crosses the notification threshold
    /// (controlled by `RegionDownloader.incrementInPercentageNotification`).
    ///
    /// This is the main progress callback. It is not called for every tile — only when the
    /// downloaded percentage surpasses the next multiple of `incrementInPercentageNotification`.
    ///
    /// - Parameters:
    ///   - regionDownloader: The `RegionDownloader` instance that triggered the callback.
    ///   - percentage: The current download percentage (0.0 – 100.0).
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double)

    /// Called when all tiles in the region have been processed (successfully downloaded or failed).
    ///
    /// This is the terminal callback. After this, no further delegate calls will be made
    /// unless `start()` is called again.
    ///
    /// - Parameters:
    ///   - regionDownloader: The `RegionDownloader` instance that triggered the callback.
    ///   - tilesDownloaded: The total number of tiles processed (`successfulTileDownloads + failedTileDownloads`).
    func regionDownloader(_ regionDownloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber)

    /// Called once before the download loop begins.
    ///
    /// Use this to prepare the UI, reset state, or log the start of a download.
    ///
    /// - Parameters:
    ///   - regionDownloader: The `RegionDownloader` instance that triggered the callback.
    ///   - totalTiles: The total number of tiles that will be attempted.
    ///   - region: The `TileCoordsRegion` being downloaded.
    ///   - mapCache: The `MapCacheProtocol` instance used to fetch and store tiles.
    ///
    /// # Example
    /// ```swift
    /// func regionDownloader(_ downloader: RegionDownloader, willStartDownloading totalTiles: TileNumber, region: TileCoordsRegion, mapCache: MapCacheProtocol) {
    ///     print("Starting download of \(totalTiles) tiles at zoom \(region.zoomRange.min)–\(region.zoomRange.max)")
    /// }
    /// ```
    func regionDownloader(_ regionDownloader: RegionDownloader, willStartDownloading totalTiles: TileNumber, region: TileCoordsRegion, mapCache: MapCacheProtocol)

    /// Called each time a tile is successfully downloaded and cached.
    ///
    /// This can fire hundreds or thousands of times. Avoid performing expensive work here;
    /// if you need to update the UI, dispatch to the main queue.
    ///
    /// - Parameters:
    ///   - regionDownloader: The `RegionDownloader` instance that triggered the callback.
    ///   - tileCoords: The coordinates (zoom, x, y) of the successfully downloaded tile.
    ///   - dataSize: The size of the tile data in bytes.
    ///
    /// # Example
    /// ```swift
    /// func regionDownloader(_ downloader: RegionDownloader, didDownloadTileAt tileCoords: TileCoords, dataSize: Int) {
    ///     print("✓ Tile z:\(tileCoords.zoom) x:\(tileCoords.tileX) y:\(tileCoords.tileY) — \(dataSize) bytes")
    /// }
    /// ```
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadTileAt tileCoords: TileCoords, dataSize: Int)

    /// Called each time a tile fails to download.
    ///
    /// This can fire hundreds or thousands of times. Avoid performing expensive work here;
    /// if you need to update the UI, dispatch to the main queue.
    ///
    /// - Parameters:
    ///   - regionDownloader: The `RegionDownloader` instance that triggered the callback.
    ///   - tileCoords: The coordinates (zoom, x, y) of the tile that failed.
    ///   - error: The error returned by the cache or network layer.
    ///
    /// # Example
    /// ```swift
    /// func regionDownloader(_ downloader: RegionDownloader, didFailToDownloadTileAt tileCoords: TileCoords, error: Error) {
    ///     print("✗ Tile z:\(tileCoords.zoom) x:\(tileCoords.tileX) y:\(tileCoords.tileY) – \(error.localizedDescription)")
    /// }
    /// ```
    func regionDownloader(_ regionDownloader: RegionDownloader, didFailToDownloadTileAt tileCoords: TileCoords, error: Error)
}

public extension RegionDownloaderDelegate {
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double) {}
    func regionDownloader(_ regionDownloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber) {}
    func regionDownloader(_ regionDownloader: RegionDownloader, willStartDownloading totalTiles: TileNumber, region: TileCoordsRegion, mapCache: MapCacheProtocol) {}
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadTileAt tileCoords: TileCoords, dataSize: Int) {}
    func regionDownloader(_ regionDownloader: RegionDownloader, didFailToDownloadTileAt tileCoords: TileCoords, error: Error) {}
}
