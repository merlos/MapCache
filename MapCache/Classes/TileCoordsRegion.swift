//
//  MapRegion.swift
//  MapCache
//
//  Created by merlos on 13/06/2019.
//

import Foundation



/// 3 dimensional region in a tile map.
/// The three dimensions are:
///  - latitude (y)
///  - longitude (x)
///  - zoom (z)
///
/// A region is represented by two `TileCoords` one holds
/// the topLeft corner and the other the bottomRight corner.
///
/// Notice that, in general, map UIs represent an infinite scroll in the
/// longitude (x) axis, when the map ends, it is displayed the beginning.
///
/// In this scenario, if we allow user to pick two points to select a region,
/// we may end up with a
///
///     +---------------------++---------------------++---------------------+
///     |                     ||                     ||                     |
///     |             * P1    ||                     ||                     |
///     |                     ||                     ||                     |
///     |       Map 1         ||        Map 2        ||       Map 3         |
///     |                     ||                     ||                     |
///     |                     ||  * P2               ||                     |
///     |                     ||                     ||                     |
///     +---------------------++---------------------++---------------------+
///
///
class TileCoordsRegion {

    // Top left coordinate
    var topLeft : TileCoords
    var bottomRight : TileCoords
    
    var zoomRange: ZoomRange {
        get {
            let z1 = topLeft.zoom
            let z2 = topLeft.zoom
            if z1 >= z2 {
                return ZoomRange(min: z1, max: z2)!
            }
            return ZoomRange(min: z2, max: z1)!
        }
    }

    /// The region will be the area that holds the line from any top left point (P1) to any
    /// bottom rightpoint 2 (P2)
    init?(topLeftLatitude: Double, topLeftLongitude: Double, bottomRightLatitude: Double, bottomRightLongitude: Double, minZoom: UInt8, maxZoom: UInt8) {
        guard let _topLeft = TileCoords(latitude: topLeftLatitude, longitude: topLeftLongitude, zoom: minZoom) else { return nil }
        guard let _bottomRight = TileCoords(latitude: bottomRightLatitude, longitude: bottomRightLongitude, zoom: maxZoom) else { return nil}
        topLeft = _topLeft
        bottomRight = _bottomRight
    }
    
    /// The region will be the area that holds the line from any top left point (P1) to any
    /// bottom rightpoint 2 (P2)
    /// For example, in this map:
    ///
    ///     +---------------------++---------------------++---------------------+
    ///     |               P1    ||                     ||                     |
    ///     |                * . .||. +                  ||                     |
    ///     |                . \  ||  ·                  ||                     |
    ///     |       Map 1    .  \ ||  ·     Map 2        ||       Map 3         |
    ///     |                .   \||  ·                  ||                     |
    ///     |                .    \|  ·                  ||                     |
    ///     |                .    |\  ·                  ||                     |
    ///     |                .    ||\ ·                  ||                     |
    ///     |                .    || \·                  ||                     |
    ///     |                + . .||. * P2               ||                     |
    ///     +---------------------++---------------------++---------------------+
    ///    -180                180 -180                 180
    ///
    /// The area will be the one denoted with the dots.
    ///
    init(topLeft: TileCoords, bottomRight: TileCoords) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }
    
    func tileRanges(forZoom zoom: Zoom) -> [TileRange]? {
        return nil
    }
    func tileRanges() -> [TileRange]? {
        return nil
    }
}
