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


class TileCoords {
    static public func validate(longitude: Double) throws -> Void {
        if longitude < -180.00 {
            throw LongitudeError.overflowMin
        } else if longitude > 180.00 {
            throw LongitudeError.overflowMax
        }
    }
    
    static public func validate(latitude: Double) throws -> Void {
        if latitude < -90.00 {
            throw LatitudeError.overflowMin
        } else if latitude > 90.00 {
            throw LatitudeError.overflowMax
        }
    }
    
    static public func validate(zoom: UInt8) throws -> Void {
        if zoom > 19 {
            throw ZoomError.largerThan19
        }
    }
    
    static public func longitudeToTileX(longitude: Double, zoom: UInt8 ) throws -> UInt64 {
        try TileCoords.validate(zoom: zoom)
        try TileCoords.validate(longitude: longitude)
        return UInt64(floor((longitude + 180) / 360.0 * pow(2.0, Double(zoom))))
    }
    
    static public func latitudeToTileY(latitude: Double, zoom: UInt8) throws -> UInt64{
        try TileCoords.validate(zoom: zoom)
        try TileCoords.validate(latitude: latitude)
        return UInt64(floor((1 - log( tan( latitude * Double.pi / 180.0 ) + 1 / cos( latitude * Double.pi / 180.0 )) / Double.pi ) / 2 * pow(2.0, Double(zoom))))
    }
    
    static public func tileXToLongitude(tileX: UInt64, zoom: UInt8) throws -> Double {
        try TileCoords.validate(zoom: zoom)
        let n : Double = pow(2.0, Double(zoom))
        let longitude =  (Double(tileX) / n) * 360.0 - 180.0
        do {
            try TileCoords.validate(longitude: longitude)
        } catch {
            throw TileError.overflow
        }
        return longitude
    }
    
    static public func tileYToLatitude(tileY: UInt64, zoom: UInt8) throws -> Double {
        try TileCoords.validate(zoom: zoom)
        let n : Double = pow(2.0, Double(zoom))
        let latitude = atan( sinh (.pi - (Double(tileY) / n) * 2 * Double.pi)) * (180.0 / .pi)
        do {
            try TileCoords.validate(latitude: latitude)
        } catch {
            throw TileError.overflow
        }
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
    
    public init(tileX: UInt64, tileY: UInt64, zoom: UInt8) throws {
        try set(zoom: zoom)
        try set(tileX: tileX, tileY: tileY)
    }
    
    public init(latitude: Double, longitude: Double, zoom: UInt8) throws {
        try set(zoom: zoom)
        try set(latitude: latitude, longitude: longitude)
    }
}
