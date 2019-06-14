//
//  TileRange.swift
//  MapCache
//
//  Created by merlos on 13/06/2019.
//

import Foundation

enum TileRangeError: Error {
    case TileCoordCreation
}
// For a particular zoom level, defines a range of tiles
//
// minTileX <= maxTileX
// minTileY <= maxTileY
struct TileRange: Sequence {
    var zoom: Zoom
    var minTileX: TileNumber
    var maxTileX: TileNumber
    var minTileY: TileNumber
    var maxTileY: TileNumber
    
    ///
    /// difference between X
    var diffX : TileNumber {
        get {
            return maxTileX - minTileX
        }
    }
    
    ///
    /// difference between maxTileY and minTileY
    var diffY : TileNumber {
        get {
            return maxTileY - minTileY
        }
    }
        
    func makeIterator() -> TileRangeIterator{
            return TileRangeIterator(self)
    }
}

