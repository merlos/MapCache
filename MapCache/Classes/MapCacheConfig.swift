//
//  MapCacheConfig.swift
//  MapCache
//
//  Created by merlos on 13/05/2019.
//

import Foundation

public struct MapCacheConfig  {
    
    public var tileUrlTemplate: String = "https://${s}.tile.openstreetmap.org/${z}/${x}/${y}.png"
    
    public var subdomains: [String] = ["a","b","c"]
    
    public var useCache: Bool = true
    
    public var cacheName: String = "MapCache"
    
    public var capacity: UInt64 = UINT64_MAX
    
    public init() {
        
    }
    public init(withTileUrlTemplate: String)  {
        tileUrlTemplate = withTileUrlTemplate
    }
    
    public func randomSubdomain() -> String? {
        if subdomains.count == 0 {
            return nil
        }
        let rand = Int(arc4random_uniform(UInt32(subdomains.count)))
        return subdomains[rand]
    }
}
