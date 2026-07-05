//
//  LoadTileMode.swift
//  MapCache
//
//  Created by merlos on 09/05/2020.
//

import Foundation

/// Defines the strategies that can be used for retrieving the tiles from the cache
/// Used by `MapCache.loadTile()` method.
///
/// - SeeAlso: `MapCache`, `MapCacheConfig`

public enum LoadTileMode {
    
    /// Default. If the tile exists in the cache, return it, otherwise, fetch it from server (and cache the result).
    case cacheThenServer
    
    /// Always get the latest version from the server.
    /// If the tile is cached it will check if it is the latest version (eTag). If the cached tile is not the last one, it will ask for it to the server (updating the cache)
    /// If there is any issue getting the tile from the server (f.i. network is down), it uses the cached version.
    ///
    case serverThenCache
          
    /// Only return data from cache.
    /// Useful for fully offline preloaded maps.
    /// If the tile does not exist returns error.
    case cacheOnly
    
    /// Always return the tile from the server, as well as updating the cache.
    /// This mode may be useful for donwloading a whole map region.
    /// If a tile was not downloaded fron the server error is returned.
    /// Always downloads and save to cache (does not use eTags)
    case serverOnly
   }
