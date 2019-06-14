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

    /// difference between max zoom and min zoom
    var diffZoom: Zoom {
        get {
            return max - min
        }
    }
    
    /// Number of zooms in this range
    ///
    /// Example:
    ///
    ///     let zR = ZoomRange(2,2)
    ///     print(zR.count) // => 1
    
    var count: Zoom {
        get {
            return diffZoom + 1
        }
    }
    
    ///
    /// [z1, z1+1, z1+2,..., z2-1, z2]
    init?(_ z1: Zoom, _ z2: Zoom) {
        do {
            try TileCoords.validate(zoom: z1)
            try TileCoords.validate(zoom: z2)
        } catch {
            return nil
        }
        self.min = z1 > z2 ? z2 : z1
        self.max = z1 > z2 ? z1 : z2
    }
    
    func toArray() -> [Zoom] {
        var ret : [Zoom] = []
        for i in min...max {
            ret.append(i)
        }
        return ret
    }
}
