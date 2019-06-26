//
//  RegionDownloaderDelegate.swift
//  MapCache
//
//  Created by merlos on 18/06/2019.
//

import Foundation

///
/// Delegate protocol of `RegionDownloader`
///
///
protocol RegionDownloaderDelegate: class {
    
    /// Did download the percentage
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double)
    
    /// Did download finish
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadFinish tilesDownloaded: TileNumber)
    
    
}
