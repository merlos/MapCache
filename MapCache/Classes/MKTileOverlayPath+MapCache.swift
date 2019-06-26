//
//  MKTileOverlay+MapCache.swift
//  MapCache
//
//  Created by merlos on 18/06/2019.
//

import Foundation
import MapKit

/// Extension to ease MapCache stuff :)
///
extension MKTileOverlayPath {
    
    /// Creates a MkTileOverlayPath from a MapCache `TileCoords`
    init(tileCoords: TileCoords) {
        self.init()
        x = Int(tileCoords.tileX)
        y = Int(tileCoords.tileY)
        z = Int(tileCoords.zoom)
    }
}
