//
//  TileRangeOperator.swift
//  MapCache
//
//  Created by merlos on 13/06/2019.
//

import Foundation

struct TileRangeIterator: IteratorProtocol {
    let range: TileRange
    var counter: UInt64
    let maxCounter : UInt64
    init(_ range: TileRange) {
        self.range = range
        counter = 0
        maxCounter = (range.diffX) * (range.diffY)
    }
    
    mutating func next() -> TileCoords? {
        guard counter <= maxCounter else { return nil }
        let currentColumn = counter % (range.diffX)
        let currentRow = (range.diffX > 0) ? UInt64(counter/range.diffX) : 0
        let x = range.minTileX + currentColumn
        let y = range.minTileY + currentRow
        counter += 1
        guard let nextTileCoords = TileCoords(tileX: x, tileY: y, zoom: range.zoom)
            else {
                return nil
        }
        return nextTileCoords
    }
}
