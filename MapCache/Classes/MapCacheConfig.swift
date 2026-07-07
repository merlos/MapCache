//
//  MapCacheConfig.swift
//  MapCache
//
//  Created by merlos on 13/05/2019.
//

import Foundation
import CoreGraphics


///
/// Settings of your MapCache.
///
///
public struct MapCacheConfig  {
   
    /// Each time a tile is going to be retrieved from the server its x,y and z (zoom) values are plugged into this URL template.
    ///
    /// Default value `"https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png`
    ///
    /// Where
    ///   1. `{s}` Replaced with one of the subdomains defined in `subdomains`.
    ///   2. `{z}` Replaced with the zoom level value.
    ///   3. `{x}` Replaced with the position of the tile in the X asis for this zoom level
    ///   4. `{y}` Replaced with the position of the tile in the X asis for this zoom level
    ///
    /// - SeeAlso: [Tiles servers in OpenStreetMap wiki](https://en.wikipedia.org/wiki/Tiled_web_map)
    /// - SeeAlso: [Tiled we maps in wikipedia](https://en.wikipedia.org/wiki/Tiled_web_map)
    public var urlTemplate: String = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    
    /// Subdomains used on the `urlTemplate`
    public var subdomains: [String] = ["a","b","c"]
    
    ///
    /// It must be smaller or equal than `maximumZ`
    ///
    /// Default value is 0.
    public var minimumZ: Int = 0
    
    ///
    /// Maximum supported zoom by the tile server
    ///
    /// Tiles with a z zoom beyond `maximumZ` supported by the tile server will return a HTTP 404 error.
    ///
    /// Values vary from server to server. For example OpenStreetMap supports 19, but OpenCycleMap supports 22.
    /// The maximum value that can be set is `TileCoords.maxZoom` (25).
    ///
    /// Default value: 19. If 0 or negative is set iOS default value (i.e. 21).
    ///
    /// - SeeAlso:  [OpenStreetMap Wiki Slippy map tilenames](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames)
    ///
    public var maximumZ: Int = 19

    ///
    /// If set to true when zooming in beyond `maximumZ` the tiles at `maximumZ` will be upsampled and shown.
    /// This mitigates the issue of showing an empty map when zooming in beyond `maximumZ`.
    /// 
    /// `maximumZ` is vital to zoom working, make sure it is properly set.
    ///
    public var overZoomMaximumZ: Bool = true
    
    ///
    /// Name of the cache
    /// A folder will be created with this name all files will be stored in that folder
    ///
    /// This is useful if you want to have different caches for different purposes as well as use the same MapCache in different parts of your application.
    /// 
    /// Default value "MapCache"
    public var cacheName: String = "MapCache"
    
    ///
    /// Cache capacity in bytes. When the cache exceeds this size, the least recently used tiles are deleted.
    /// By default is infinite (i.e. UINT64_MAX). 
    public var capacity: UInt64 = UINT64_MAX
    
    ///
    /// Optional custom base URL for the cache directory.
    ///
    /// When set, overrides the default temporary `NSCachesDirectory/DiskCache/` path.
    /// Useful for permanent storage, for example pointing to `applicationSupportDirectory`.
    ///
    /// Default is `nil`, which uses the default temporary cache location (`DiskCache.defaultBaseURL()`).
    ///
    /// Example usage:
    /// ```swift
    /// let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    /// config.baseURL = appSupport.appendingPathComponent("MapCacheTiles", isDirectory: true)
    /// ```
    ///
    public var baseURL: URL? = nil
    
    ///
    /// Tile size of the tile. Default is 256x256
    ///
    public var tileSize: CGSize = CGSize(width: 256, height: 256)
    
    
    ///
    /// Load tile  mode.
    /// Sets the strategy to be used when loading a tile.
    /// By default loads from the cache and if it fails loads from the server
    ///
    /// - SeeAlso: `LoadTileMode`
    
    public var loadTileMode: LoadTileMode = .cacheThenServer
    
    ///
    /// Constructor with all the default values.
    ///
    public init() {
    }
    
    ///
    ///Constructor that overwrites the `urlTemplate``
    ///
    /// - Parameter withUrlTemplate: is the string of the `urlTemplate`
    ///
    public init(withUrlTemplate urlTemplate: String)  {
        self.urlTemplate = urlTemplate
    }
    
    ///
    /// Selects one of the subdomains randomly.
    ///
    public func randomSubdomain() -> String? {
        if subdomains.count == 0 {
            return nil
        }
        let rand = Int(arc4random_uniform(UInt32(subdomains.count)))
        return subdomains[rand]
    }
    
    /// Keeps track of the index of the last subdomain requested for round robin
    private var subdomainRoundRobin: Int = 0
    
    /// Round Robin algorithm
    /// If subdomains are a,b,c then it makes requests to a,b,c,a,b,c,a,b,c...
    ///
    /// It uniformly makes requests to all the subdomains.
    public mutating func roundRobinSubdomain() -> String? {
        if subdomains.count == 0 {
            return nil
        }
        self.subdomainRoundRobin = (self.subdomainRoundRobin + 1)  % subdomains.count
        return subdomains[subdomainRoundRobin]
    }
}
