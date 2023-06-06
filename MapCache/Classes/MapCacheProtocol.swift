//
//  MapCacheProtocol.swift
//  MapCache
//
//  Created by merlos on 29/06/2019.
//

import Foundation
import MapKit

///
///  This protocol shall be implemented by any cache used in MapCache.
///
/// - SeeAlso: [Main Readme page](/)
///
public protocol MapCacheProtocol {

    /// An instance of `MapCacheConfig`
    var config: MapCacheConfig { get set }
    
    /// The implementation shall convert a tile path into a URL object
    ///
    /// Typically it will use the `config.urlTemplate` and `config.subdomains`.
    ///
    /// An example of implementation can be found in the class`MapCache`
    func url(forTilePath path: MKTileOverlayPath) -> URL
    
    ///
    /// The implementation shall return either the tile as a Data object or an Error if the tile could not be retrieved.
    ///
    /// - SeeAlso [MapKit.MkTileOverlay](https://developer.apple.com/documentation/mapkit/mktileoverlay)
    func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void)
    
    /// Cache specified tile
    /// - Parameters:
    ///   - path: the path of the tile to be cache
    ///   - update: indicates to re-download from the server even if the cache already contains this tile
    ///   - result: result is the closure that will be run once the tile or an error is received.
    func cacheTile(at path: MKTileOverlayPath, update: Bool, result: @escaping (_ size: Int, Error?) -> Void)
    
}
