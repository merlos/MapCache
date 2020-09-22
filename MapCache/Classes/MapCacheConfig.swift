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
   
    ///
    public var urlTemplate: String = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    
    public var subdomains: [String] = ["a","b","c"]
    
    ///
    /// Maximum supported zoom by the tile server
    ///
    /// If the tile server supported zoom is smaller than `maximumZ` tiles won't be rendered as a HTTP 404 error
    /// will be returned by the server for not supported zoom levels.
    ///
    /// Values vary from server to server. For example OpenStreetMap supports 19, but  OpenCycleMap supports 22
    /// - see https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    ///
    /// Default value: 19. If 0 or negative is set iOS default value (i.e. 21)
    public var maximumZ: Int = 19
    
    ///
    /// It must be smaller or equal than `maximumZ`
    ///
    /// Default value is 0.
    public var minimumZ: Int = 0
    
    ///
    /// Name of the cache
    /// A folder will be created with this name all files will be stored in that folder
    ///
    /// Default value "MapCache"
    public var cacheName: String = "MapCache"
    
    ///
    /// Cache capacity in bytes
    ///
    public var capacity: UInt64 = UINT64_MAX
    
    ///
    /// Tile size
    ///
    public var tileSize: CGSize = CGSize(width: 256, height: 256)
    
    ///
    /// Zoom
    ///
    /// When zooming in beyond `maximumZ` the tiles at `maximumZ` will be upsampled and shown.
    /// This is to mitigate the issue of showing an empty map when zooming in beyond `maximumZ`.
    /// `maximumZ` is vital to zoom working, make sure it is properly set.
    public var useZoom: Bool = false
    
    ///
    /// Load tile  mode.
    /// Sets the strategy when loading a tile. By default loads from the cache and if it fails loads from the server
    ///
    public var loadTileMode: LoadTileMode = .cacheThenServer
    
    public init() {
    }
    
    public init(withUrlTemplate urlTemplate: String)  {
        self.urlTemplate = urlTemplate
    }
    
    public func randomSubdomain() -> String? {
        if subdomains.count == 0 {
            return nil
        }
        let rand = Int(arc4random_uniform(UInt32(subdomains.count)))
        return subdomains[rand]
    }
    
    /// Keeps track of the last subdomain requested.
    private var subdomainRoundRobin: Int = 0
    
    /// Round Robin algorithm
    /// If subdomains are a,b,c then it makes requests to a,b,c,a,b,c,a,b,c...
    ///
    /// It uniformly makes requests
    public mutating func roundRobinSubdomain() -> String? {
        if subdomains.count == 0 {
            return nil
        }
        self.subdomainRoundRobin = (self.subdomainRoundRobin + 1)  % subdomains.count
        return subdomains[subdomainRoundRobin]
    }
}
