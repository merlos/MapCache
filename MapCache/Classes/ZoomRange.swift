//
//  ZoomRange.swift
//  MapCache
//
//  Created by merlos on 13/06/2019.
//

import Foundation


/// A range of zooms
struct ZoomRange {
    
    /// Minimum zoom in this range
    let min: Zoom
    
    /// Maximum zoom in this range
    let max: Zoom

    ///
    init?(min: Zoom, max: Zoom) {
        if min > max {
            return nil
        }
        if min > TileCoords.maxZoom {
            return nil
        }
        if max > TileCoords.maxZoom {
            return nil
        }
        self.min = min
        self.max = max
    }

}
