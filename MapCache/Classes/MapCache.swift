//
//  MapCache.swift
//  MapCache
//
//  Created by merlos on 13/05/2019.
//

import Foundation
import MapKit

/// The real brain
public class MapCache : NSObject {
    
    public var config : MapCacheConfig
    public var diskCache : DiskCache
    let operationQueue = OperationQueue()
    
    public init(withConfig config: MapCacheConfig ) {
        self.config = config
        diskCache = DiskCache(withName: config.cacheName, capacity: config.capacity)
    }
    
    public func url(forTilePath path: MKTileOverlayPath) -> URL {
        //print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        var urlString = config.urlTemplate.replacingOccurrences(of: "{z}", with: String(path.z))
        urlString = urlString.replacingOccurrences(of: "{x}", with: String(path.x))
        urlString = urlString.replacingOccurrences(of: "{y}", with: String(path.y))
        urlString = urlString.replacingOccurrences(of: "{s}", with: config.randomSubdomain() ?? "")
        print("MapCache::url() urlString: \(urlString)")
        return URL(string: urlString)!
    }
    
    public func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        // Use cache
        // is the file alread in the system?
        let cacheKey = "\(config.urlTemplate)-\(path.x)-\(path.y)-\(path.z)"
        let fetChfailure = { (error: Error?) -> () in
            print ("MapCache::loadTile() Not found! cacheKey=\(cacheKey)" )
        }
        let fetchSuccess = {(data: Data) -> () in
            print ("MapCache::loadTile() found! cacheKey=\(cacheKey)" )
            result (data, nil)
        }
        
        diskCache.fetchData(forKey: cacheKey, failure: fetChfailure, success: fetchSuccess)
        let url = self.url(forTilePath: path)
        print ("MapCache::loadTile() url=\(url)")
        print("Requesting data....");
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            self.diskCache.setData(data, forKey: cacheKey)
            print ("CachedTileOverlay:: saved cacheKey=\(cacheKey)" )
            result(data,nil)
        }
        task.resume()
    }
    
    public var size: UInt64 {
        get  {
            return diskCache.size
        }
    }
    
    public func calculateSize() -> UInt64 {
        return diskCache.calculateSize()
    }
    
    public func clear(completition: (() -> ())? ) {
        diskCache.removeAllData(completition)
    }
    
}
