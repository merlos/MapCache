//
//  CachedTileOverlay.swift
//
//  Base source code comes from Open GPX Tracker http://github.com/iOS-Open-GPX-Tracker
//
//

import Foundation
import MapKit


///
/// Overwrites the default overlay to store downloaded images
///
public class CachedTileOverlay : MKTileOverlay {
    
    /// Tells loadTile method if the tile shall be loaded rom the app cache.
    public var useCache: Bool = true
    
    
    public var config: MapCacheConfig?
    
    public init(mapCacheConfig: MapCacheConfig) {
        super.init(urlTemplate: mapCacheConfig.tileUrlTemplate)
        self.config = mapCacheConfig
    }
    
    ///
    /// Generates the URL for the tile to be requested.
    /// It replaces the values of {z},{x} and {y} in the urlTemplate defined in GPXTileServer
    ///
    /// -SeeAlso: GPXTileServer
    ///
    override public func url(forTilePath path: MKTileOverlayPath) -> URL {
        //print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        var urlString = urlTemplate?.replacingOccurrences(of: "{z}", with: String(path.z))
        urlString = urlString?.replacingOccurrences(of: "{x}", with: String(path.x))
        urlString = urlString?.replacingOccurrences(of: "{y}", with: String(path.y))
        
        //get random subdomain
        let subdomains = "abc"
        let rand = arc4random_uniform(UInt32(subdomains.count))
        let randIndex = subdomains.index(subdomains.startIndex, offsetBy: String.IndexDistance(rand));
        urlString = urlString?.replacingOccurrences(of: "{s}", with:String(subdomains[randIndex]))
        print("CachedTileOverlay:: url() urlString: \(urlString ?? "no url")")
        return URL(string: urlString!)!
    }
    
    ///
    /// Loads the tile from the network or from cache
    ///
    /// If the internal app cache is activated,it tries to get the tile from it.
    /// If not, it uses the default system cache (managed by the OS).
    ///
    override public func loadTile(at path: MKTileOverlayPath,
                           result: @escaping (Data?, Error?) -> Void) {
        let url = self.url(forTilePath: path)
        print ("CachedTileOverlay::loadTile() url=\(url) useCache: \(useCache)")
    
        if !self.useCache {
            print("lay:: not using cache")
            return super.loadTile(at: path, result: result)
        }
        // Use cache
        
        return super.loadTile(at: path, result: result)
    }
}
