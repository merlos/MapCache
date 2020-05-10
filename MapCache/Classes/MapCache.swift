//
//  MapCache.swift
//  MapCache
//
//  Created by merlos on 13/05/2019.
//

import Foundation
import MapKit


/// The real brain
public class MapCache : MapCacheProtocol {
    
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
        urlString = urlString.replacingOccurrences(of: "{s}", with: config.roundRobinSubdomain() ?? "")
        Log.debug(message: "MapCache::url() urlString: \(urlString)")
        return URL(string: urlString)!
    }
    
    public func cacheKey(forPath path: MKTileOverlayPath) -> String {
        return "\(config.urlTemplate)-\(path.x)-\(path.y)-\(path.z)"
    }
    
    
    public func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        
        let key = cacheKey(forPath: path)
        
        // Feches tile from server. If it is found updates the cache
        func fetchTileFromServer(failure fail: ((Error?) -> ())? = nil,
                                 success succeed: @escaping (Data) -> ()) {
            let url = self.url(forTilePath: path)
            print ("MapCache::fetchTileFromServer() url=\(url)")
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    print("!!! MapCache::fetchTileFromServer Error for url= \(url)")
                    fail!(error)
                    return
                }
                guard let data = data else {
                    fail!(nil)
                    return
                }
                self.diskCache.setData(data, forKey: key)
                print ("MapCache::fetchTileFromServer:: Data received saved cacheKey=\(key)" )
                succeed(data)
            }
            task.resume()
        }
        
       // Tries to load the tile from the server.
       // If it fails returns error to the caller.
        let tileFromServerFallback = { () -> () in
            print ("MapCache::tileFromServerFallback:: key=\(key)" )
            fetchTileFromServer(failure: {error in result(nil, error)},
                                success: {data in result(data, nil)})
        }
        
        // Tries to load the tile from the cache.
        // If it fails returns error to the caller.
        let tileFromCacheFallback = { () -> () in
            self.diskCache.fetchDataSync(forKey: key,
                    failure: {error in result(nil, error)},
                    success: {data in result(data, nil)})
            
        }
        
        switch config.loadTileMode {
        case .cacheThenServer:
            diskCache.fetchDataSync(forKey: key,
                                    failure: {error in tileFromServerFallback()},
                                    success: {data in result(data, nil) })
        case .serverThenCache:
            fetchTileFromServer(failure: {error in tileFromCacheFallback()},
                                success: {data in result(data, nil) })
        case .serverOnly:
            fetchTileFromServer(failure: {error in result(nil, error)},
                                success: {data in result(data, nil)})
        case .cacheOnly:
            diskCache.fetchDataSync(forKey: key,
                failure: {error in result(nil, error)},
                success: {data in result(data, nil)})
        }
    }
    
    public var diskSize: UInt64 {
        get  {
            return diskCache.diskSize
        }
    }
    
    public func calculateDiskSize() -> UInt64 {
        return diskCache.calculateDiskSize()
    }
    
    public func clear(completition: (() -> ())? ) {
        diskCache.removeAllData(completition)
    }
    
}
