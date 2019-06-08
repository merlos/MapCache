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
    
    init(config: MapCacheConfig ) {
        self.config = config
    }
    
    func getTile(_ tilePath: MKTileOverlayPath) {
       
        
    }
    
    func setTile(_ data: Data, forPath: MKTileOverlayPath) {
        
    }
    
    func removeTile(_ tileUrl: String) {
        
    }
    
    func cacheSize() {
        
    }
    
    func removeAll() {
        
    }
    
}
