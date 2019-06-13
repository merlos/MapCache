//
//  TileCoords.swift
//  MapCache
//
//  Created by merlos on 10/06/2019.
//

import Foundation

enum ZoomError: Error {
    case largerThan19
}

enum LatitudeError: Error {
    case overflowMin
    case overflowMax
}
enum LongitudeError: Error {
    case overflowMin
    case overflowMax
}

enum TileError: Error {
    case overflow
}


/// Class to convert from Map Tiles to coordinates and from coordinates to tiles
///
/// Coordinates (latitude and longitude) are ALWAYS expressed in degrees
///
/// z = zoom
/// Size of the square: 2^z x 2^z
///
///     (-180,85.0511)      (180,85.0511)  <----- coord (lat, long)
///     0,0                 2^z, 0         <------ tile number (x,y)
///     +-------------------+
///     |                   |
///     |                   |
///     |                   |
///     +-------------------+
///    0,2^z          2^z, 2^z
/// (-180,-85.0511)   (180,-85.0511)
///
/// All the wisdom of this class comes from:
/// https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
///
class TileCoords {
    
    /// Max value of latitude that can be retrieved with tiles (-85.0511 degrees)
    static let maxLatitude : Double = 85.0511
    
    /// Min value of latitude that can be retrieved with tiles (-85.0511 degrees)
    static let minLatitude : Double = -85.0511
    
    /// Max value of a longitude (<180.0).
    /// Any longitude has to be strictly minor than this value 180.0
    static let maxLongitude : Double = 180.0
    
    /// Min value of a longitude (>=180.0)
    /// Any longitude has to be mayor or equal to this value -180.0.
    static let minLongitude : Double = -180.0
    
    
    /// Max zoom supported in tile servers (19)
    static let maxZoom : UInt8 = 19
    
    /// Min zoom supported (0)
    static let minZoom : UInt8 = 0
    
    /// Based on current zoom it indicates what is the max tile
    static public func maxTile(forZoom zoom: UInt8) -> UInt64 {
         return UInt64(pow(2.0, Double(zoom)) - 1 )
    }
    
    /// validates if longitude is between min and max allowed longitudes
    /// Throws LongitudeError
    static public func validate(longitude: Double) throws -> Void {
        if longitude < minLongitude {
            throw LongitudeError.overflowMin
        } else if longitude >= maxLongitude {
            throw LongitudeError.overflowMax
        }
    }
    
    /// Validates if a latitude is between min and max allowed latitudes.
    /// Throws LongitudeError if it is not.
    static public func validate(latitude: Double) throws -> Void {
        if latitude < minLatitude {
            throw LatitudeError.overflowMin
        } else if latitude > maxLatitude {
            throw LatitudeError.overflowMax
        }
    }
    
    /// Validate zoom is less or equal to the maxZoom
    /// Throws ZoomError if is greater than maxZoom
    static public func validate(zoom: UInt8) throws -> Void {
        if zoom > maxZoom {
            throw ZoomError.largerThan19
        }
    }
    
    /// Validates if the tile is within the range for the zoom
    /// A tile must be always be less than 2^zoom.
    static public func validate(tile: UInt64, forZoom zoom: UInt8) throws -> Void {
        if tile > maxTile(forZoom: zoom) {
            throw TileError.overflow
        }
    }
    
    /// Returns the tile in the X axis for the longitude and zoom.
    /// Can throw ZoomError and LongitudeError if these are out of the boundaries.
    static public func longitudeToTileX(longitude: Double, zoom: UInt8 ) throws -> UInt64 {
        try TileCoords.validate(zoom: zoom)
        try TileCoords.validate(longitude: longitude)
        return UInt64(floor((longitude + 180) / 360.0 * pow(2.0, Double(zoom))))
    }
    
    /// Returns the tile in the Y axis for the latitude and zoom.
    /// Can throw ZoomError and LongitudeError if these are out of the boundaries.
    static public func latitudeToTileY(latitude: Double, zoom: UInt8) throws -> UInt64{
        try validate(zoom: zoom)
        try validate(latitude: latitude)
        return UInt64(floor((1 - log( tan( latitude * Double.pi / 180.0 ) + 1 / cos( latitude * Double.pi / 180.0 )) / Double.pi ) / 2 * pow(2.0, Double(zoom))))
    }
    
    /// Returns the longitude in degrees
    static public func tileXToLongitude(tileX: UInt64, zoom: UInt8) throws -> Double {
        try validate(zoom: zoom)
        try validate(tile: tileX, forZoom: zoom)
        let n : Double = pow(2.0, Double(zoom))
        let longitude =  (Double(tileX) / n) * 360.0 - 180.0
        return longitude
    }
    
    static public func tileYToLatitude(tileY: UInt64, zoom: UInt8) throws -> Double {
        try validate(zoom: zoom)
        try validate(tile: tileY, forZoom: zoom)
        let n : Double = pow(2.0, Double(zoom))
        let latitude = atan( sinh (.pi - (Double(tileY) / n) * 2 * Double.pi)) * (180.0 / .pi)
        return latitude
    }
    
    private var _zoom : UInt8 = 0
    var zoom : UInt8 {
        get {
            return _zoom
        }
    }
    
    private var _latitude: Double = 0.0
    var latitude: Double {
        get {
            return _latitude
        }
    }
    
    private var _longitude: Double = 0.0

    var longitude: Double {
        get {
            return _longitude
        }
    }
    
    private var _tileX : UInt64 = 0
    
    public var tileX: UInt64 {
        get {
         return _tileX
        }
    }
    
    private var _tileY: UInt64 = 0
    
    public var tileY : UInt64 {
        get {
            return _tileY
        }
    }
    
    
    
    public func set(zoom: UInt8) throws {
        try TileCoords.validate(zoom: zoom)
        _zoom = zoom
        _tileX = try! TileCoords.longitudeToTileX(longitude: longitude, zoom: _zoom)
        _tileY = try! TileCoords.latitudeToTileY(latitude: latitude, zoom: _zoom)
    }
    
    
    public func set(tileX: UInt64, tileY: UInt64) throws {
        _longitude = try TileCoords.tileXToLongitude(tileX: tileX, zoom: _zoom)
        _latitude = try TileCoords.tileYToLatitude(tileY: tileY, zoom: _zoom)
        _tileX = tileX
        _tileY = tileY
    }
    
    public func set(latitude: Double, longitude: Double) throws {
        
        // validate values are within the ranges
        try TileCoords.validate(latitude: latitude)
        try TileCoords.validate(longitude: longitude)
        
        // set the values
        _latitude = latitude
        _longitude = longitude
        
        //update tiles
        _tileX = try! TileCoords.longitudeToTileX(longitude: longitude, zoom: _zoom)
        _tileY = try! TileCoords.latitudeToTileY(latitude: latitude, zoom: _zoom)
    }
    
    public init?(tileX: UInt64, tileY: UInt64, zoom: UInt8) {
        do {
            try set(zoom: zoom)
            try set(tileX: tileX, tileY: tileY)
        } catch {
            return nil
        }
    }
    
    public init?(latitude: Double, longitude: Double, zoom: UInt8) {
        do {
            try set(zoom: zoom)
            try set(latitude: latitude, longitude: longitude)
        } catch {
            return nil
        }
    }
    
    public func maxTile() -> UInt64 {
        return TileCoords.maxTile(forZoom: zoom)
    }
}
