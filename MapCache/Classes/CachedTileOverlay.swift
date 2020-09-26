//
//  CachedTileOverlay.swift
//
//  Base source code comes from Open GPX Tracker http://github.com/iOS-Open-GPX-Tracker
//
//

import Foundation
import MapKit


///
/// Whenever a tile is requested by the `MapView`, it calls the `MKTileOverlay.loadTile`.
/// This class overrides the default `MKTileOverlay`to provide support to `MapCache`.
///
/// - SeeAlso: MkMapView+MapView
///
public class CachedTileOverlay : MKTileOverlay {
    
    /// A class that implements the `MapCacheProtocol`
    let mapCache : MapCacheProtocol
    
    /// If true `loadTile` uses the implementation of  the `mapCache` var. If `false`, uses the
    /// default `MKTileOverlay`implementation from Apple.
    public var useCache: Bool = true
    
    /// Constructor.
    /// - Parameter withCache: the cache to be used on loadTile
    public init(withCache cache: MapCacheProtocol) {
        mapCache = cache
        super.init(urlTemplate: mapCache.config.urlTemplate)
    }
    
    ///
    /// Generates the URL for the tile to be requested.
    /// It replaces the values of {z},{x} and {y} in the urlTemplate defined in GPXTileServer
    ///
    /// - SeeAlso: GPXTileServer
    ///
    override public func url(forTilePath path: MKTileOverlayPath) -> URL {
        //print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        return mapCache.url(forTilePath: path)
    }
    
    ///
    /// Depending on  `useCache`value, when invoked, will load the tile using the standard OS
    /// implementation or from the cache.
    ///
    override public func loadTile(at path: MKTileOverlayPath,
                           result: @escaping (Data?, Error?) -> Void) {
        if !self.useCache { // Use cache by use cache is not set.
           // print("loadTile:: not using cache")
            return super.loadTile(at: path, result: result)
        } else {
           return mapCache.loadTile(at: path, result: result)
        }
    }
}
