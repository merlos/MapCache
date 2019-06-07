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
    
    public var config: MapCacheConfig = MapCacheConfig()
    
    let operationQueue = OperationQueue()
    
    var diskCache: DiskCache
    
    public init(mapCacheConfig: MapCacheConfig) {
        diskCache = DiskCache(withName: config.cacheName, capacity: config.capacity)
        config = mapCacheConfig
        super.init(urlTemplate: mapCacheConfig.tileUrlTemplate)
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
        urlString = urlString?.replacingOccurrences(of: "{s}", with:config.randomSubdomain() ?? "")
        //print("CachedTileOverlay:: url() urlString: \(urlString ?? "no url")")
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
        if !(config.useCache) { // Use cache by use cache is not set.
           // print("loadTile:: not using cache")
            return super.loadTile(at: path, result: result)
        }
        // Use cache
        // is the file alread in the system?
        let cacheKey = "\(self.urlTemplate ?? "none")-\(path.x)-\(path.y)-\(path.z)"
        
        let fetChfailure = { (error: Error?) -> () in
             print ("CachedTileOverlay:: Not found! cacheKey=\(cacheKey)" )
        }
        let fetchSuccess = {(data: Data) -> () in
             print ("CachedTileOverlay:: found! cacheKey=\(cacheKey)" )
            result(data, nil)
            return
        }
        diskCache.fetchData(forKey: cacheKey, failure: fetChfailure, success: fetchSuccess)
        let url = self.url(forTilePath: path)
        print ("CachedTileOverlay::loadTile() url=\(url) useCache: \(config.useCache)")
        print("Requesting data....");
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            self.diskCache.setData(data, forKey: cacheKey)
            print ("CachedTileOverlay:: saved cacheKey=\(cacheKey)" )
            result(data,nil)
        }
        task.resume()
    }
}
