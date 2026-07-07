//
//  RegionDownloaderDelegate.swift
//  MapCache
//
//  Created by merlos on 18/06/2019.
//

import Foundation

///
/// Delegate protocol of `RegionDownloader`.
/// Implement this protocol whenever  you use `RegionDownloader` it provides feedback while downloading a
/// region (f.i, downloaded %) and calls back the delegate once the download finished.
///
/// All methods have default empty implementations, making them optional.
///
public protocol RegionDownloaderDelegate: AnyObject {

    /// Did download the percentage.
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double)

    /// Did Finish Download all tiles.
    func regionDownloader(_ regionDownloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber)

    /// Called before the download starts.
    func regionDownloader(_ regionDownloader: RegionDownloader, willStartDownloading totalTiles: TileNumber, region: TileCoordsRegion, mapCache: MapCacheProtocol)

    /// Called each time a tile is successfully downloaded.
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadTileAt tileCoords: TileCoords, dataSize: Int)

    /// Called each time a tile fails to download.
    func regionDownloader(_ regionDownloader: RegionDownloader, didFailToDownloadTileAt tileCoords: TileCoords, error: Error)
}

public extension RegionDownloaderDelegate {
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double) {}
    func regionDownloader(_ regionDownloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber) {}
    func regionDownloader(_ regionDownloader: RegionDownloader, willStartDownloading totalTiles: TileNumber, region: TileCoordsRegion, mapCache: MapCacheProtocol) {}
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadTileAt tileCoords: TileCoords, dataSize: Int) {}
    func regionDownloader(_ regionDownloader: RegionDownloader, didFailToDownloadTileAt tileCoords: TileCoords, error: Error) {}
}
