//
//  MapCache.swift
//  MapCache
//
//  Created by merlos on 13/05/2019.
//

import Foundation
import MapKit


///
/// This is the main implementation of the MapCacheProtocol, the actual cache
///

open class MapCache : MapCacheProtocol {
    ///
    /// Cofiguration that will be used to set up the behavior of the `MapCache` instance
    ///
    public var config : MapCacheConfig
    
    ///
    /// It manages the physical storage of the tile images in the device
    ///
    public var diskCache : DiskCache
    
    ///
    /// Manages the queue of network requests for retrieving the tiles
    ///
    let operationQueue = OperationQueue()
    
    ///
    /// Constructor. It sets the `config` variable and initializes the `diskCache` with the name and capacity set in the config.
    ///
    /// - Parameter withConfig Cofiguration that will be used to set up the behavior of the MapCache instance
    ///
    public init(withConfig config: MapCacheConfig ) {
        self.config = config
        diskCache = DiskCache(withName: config.cacheName, capacity: config.capacity)
    }
    
    ///
    /// Returns the URL for a tile.
    ///
    /// Basically replaces in `config.urlTemplate` the substrings `{z}`,`{x}`, `{y}`
    /// with the values of the `forTilePath`
    /// If ` {s}` is defined in the template, it aplies the Round Robin algorithm.
    ///
    /// - Parameter forTilePath: is the path for the tile in (x, y, z) tile coordinates.
    ///
    /// - SeeAlso: MapCacheConfig.roundRoubinSubdomain()
    
    public func url(forTilePath path: MKTileOverlayPath) -> URL {
        //print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        var urlString = config.urlTemplate.replacingOccurrences(of: "{z}", with: String(path.z))
        urlString = urlString.replacingOccurrences(of: "{x}", with: String(path.x))
        urlString = urlString.replacingOccurrences(of: "{y}", with: String(path.y))
        urlString = urlString.replacingOccurrences(of: "{s}", with: config.roundRobinSubdomain() ?? "")
        Log.debug(message: "MapCache::url() urlString: \(urlString)")
        return URL(string: urlString)!
    }
    
    /// For the path passed as argument it creates a unique key to be used in `DiskCache`.
    ///
    /// The output is a string that has the following format `{config.urlTemplate}-{x}-{y}-{z}` where:
    ///  - config.urlTemplate is the template url template and
    ///  -  x, y and z are the coords of the path
    ///
    /// - Parameter forPath: is the path of the tile you want the cache
    
    public func cacheKey(forPath path: MKTileOverlayPath) -> String {
        return "\(config.urlTemplate)-\(path.x)-\(path.y)-\(path.z)"
    }
    
    ///
    /// Fetches tile from server.
    /// It resolves the url for the tile at the path. Then it tries to download the tile image from the server. If everything goes ok it
    /// and updates the image in `diskCache` and returns the received `Data`  through the  `sucess` closure.
    /// If something goes wrong it invokes the `failure`closure  passing the `error`returned by the system.
    ///
    /// - Parameter at: Path for the tile
    /// - Parameter failure: if the tile cannot be retrieved from the server this closure is called
    /// - Parameter success: if the image is downloaded
    
    public func fetchTileFromServer(at path: MKTileOverlayPath,
                             failure fail: ((Error?) -> ())? = nil,
                             success succeed: @escaping (Data) -> ()) {
        let url = self.url(forTilePath: path)
        print ("MapCache::fetchTileFromServer() url=\(url)")
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print("!!! MapCache::fetchTileFromServer Error for url= \(url) \(error.debugDescription)")
                fail!(error)
                return
            }
            guard let data = data else {
                print("!!! MapCache::fetchTileFromServer No data for url= \(url)")
                fail!(nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                print("!!! MapCache::fetchTileFromServer statusCode != 2xx url= \(url)")
                fail!(nil)
                return
            }
            
            succeed(data)
        }
        task.resume()
    }
    
    /// Returns the tile to be displayed on the overlay.
    /// The strategy used to retrieve the tile (i.e. from network or from the `diskCache`) depends on the `config.loadTileMode`.
    ///
    /// - Parameter at the path of the tile to be retrived
    /// - Parameter result is the closure that will be run once the tile or an error is received.
    ///
    /// - SeeAlso: `LoadTileMode`
    ///
    open func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        
        let key = cacheKey(forPath: path)
        
       // Tries to load the tile from the server.
       // If it fails returns error to the caller.
        let tileFromServerFallback = { () -> () in
            print ("MapCache::tileFromServerFallback:: key=\(key)" )
            self.fetchTileFromServer(at: path,
                                failure: {error in result(nil, error)},
                                success: {data in
                                    self.diskCache.setData(data, forKey: key)
                                               print ("MapCache::fetchTileFromServer:: Data received saved cacheKey=\(key)" )
                                    result(data, nil)})
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
            fetchTileFromServer(at: path, failure: {error in tileFromCacheFallback()},
                                success: {data in result(data, nil) })
        case .serverOnly:
            fetchTileFromServer(at: path, failure: {error in result(nil, error)},
                                success: {data in result(data, nil)})
        case .cacheOnly:
            diskCache.fetchDataSync(forKey: key,
                failure: {error in result(nil, error)},
                success: {data in result(data, nil)})
        }
    }
    
    /// Load cached tile identification information
    /// - Parameter path: the tile path
    /// - Returns: etag if present
    open func loadETag(forPath path: MKTileOverlayPath) -> String? {
        return nil
    }
    
    /// Stores the identification information of the tile
    /// - Parameter path: the tile path
    /// - Parameter etag: the identification information of the tile， If nil will delete old information
    open func saveETag(forPath path: MKTileOverlayPath, etag: String?) {
    }
    
    /// Cache specified tiles
    /// - Parameters:
    ///   - path: the path of the tile to be cache
    ///   - update: indicates to re-download from the server even if the cache already contains this tile
    ///   - result: result is the closure that will be run once the tile or an error is received.
    open func cacheTile(at path: MKTileOverlayPath, update: Bool, result: @escaping (_ size: Int, Error?) -> Void) {
        
        let key = cacheKey(forPath: path)
        let exists = diskCache.exists(forKey: key)
        
        if !update && exists {
            result(0, nil)
            return
        }
        
        print ("MapCache::cacheTileFromServer:: key=\(key)" )
        let url = self.url(forTilePath: path)
        var req = URLRequest(url: url)
        if exists {
            if let eTag = loadETag(forPath: path) {
                req.addValue(eTag, forHTTPHeaderField: "If-None-Match")
            }
        }
        
        let task = URLSession.shared.dataTask(with: req) {(data, response, error) in
            if error != nil {
                print("!!! MapCache::cacheTileFromServer Error for url= \(url) \(error.debugDescription)")
                result(0, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("!!! MapCache::cacheTileFromServer No data url= \(url)")
                result(0, nil)
                return
            }
            
            if httpResponse.statusCode == 304 {
                print("MapCache::cacheTileFromServer unmodified for url= \(url)")
                result(0, nil)
                return
            }
            
            guard let data = data else {
                print("!!! MapCache::cacheTileFromServer No data for url= \(url)")
                result(0, nil)
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("!!! MapCache::cacheTileFromServer statusCode != 2xx url= \(url)")
                result(0, nil)
                return
            }
            self.diskCache.setData(data, forKey: key)
                       print ("MapCache::cacheTileFromServer:: Data received saved cacheKey=\(key)" )
            var etag: String? = nil
            if #available(iOS 13.0, *) {
                etag = httpResponse.value(forHTTPHeaderField: "etag")
            } else {
                etag = httpResponse.allHeaderFields["Etag"] as? String
            }
            self.saveETag(forPath: path, etag: etag)
            result(data.count, nil)
        }
        task.resume()


    }
    
    //TODO review why does it have two ways of retrieving the cache size.
    
    /// Currently size of the cache
    public var diskSize: UInt64 {
        get  {
            return diskCache.diskSize
        }
    }
    
    /// Calculates the disk space allocated in dis for the cache
    /// 
    /// - SeeAlso: DiskCache
    public func calculateDiskSize() -> UInt64 {
        return diskCache.calculateDiskSize()
    }
    
    /// Clears the cache.
    /// Removes all files in the `diskCache`
    /// As it may take some time to remove all files it calls the completition closure upon finishing the removal.
    ///
    /// - Parameter completition: code to run upon the cache is cleared.
    
    public func clear(completition: (() -> ())? ) {
        diskCache.removeAllData(completition)
    }
    
}
