//
//  TileCoordsSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 10/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import MapCache

class TileCoordsSpecs: QuickSpec {
    override func spec() {
        describe("TileCoords") {
            
            let lat: Double = 10.0
            let lon: Double = 20.0
            
            let tileX: UInt64 = 568 // tile number for lon 20.0
            let tileY: UInt64 = 483 // tile number for lat 10.0
            
            let zoom: UInt8 = 10
            
            it("can initialize with lat and long") {
                let tileCoords = TileCoords(latitude: lat, longitude: lon, zoom: zoom)
                expect(tileCoords!.latitude).to(equal(lat))
                expect(tileCoords!.longitude).to(equal(lon))
                expect(tileCoords!.tileY).to(equal(tileY))
                expect(tileCoords!.tileX).to(equal(tileX))
                expect(tileCoords!.zoom).to(equal(zoom))
            }
            
            it("cannot initialize with an invalid lat, long or zoom") {
                let tileCoords1 = TileCoords(latitude: lat + 2000, longitude: lon, zoom: zoom)
                expect(tileCoords1).to(beNil())
                let tileCoords2 = TileCoords(latitude: lat, longitude: lon + 2000, zoom: zoom)
                expect(tileCoords2).to(beNil())
                let tileCoords3 = TileCoords(latitude: lat, longitude: lon + 2000, zoom: zoom + 20)
                expect(tileCoords3).to(beNil())
            }
            it ("can validate max and mins") {
                //zoom
                try! TileCoords.validate(zoom: 0)
                expect { try TileCoords.validate(zoom: 20)}.to(throwError())
                //Tiles
                try! TileCoords.validate(tile: 1, forZoom: 10)
                expect { try TileCoords.validate(tile: 1024, forZoom: 10)}.to(throwError())
                //Coordinates
                try! TileCoords.validate(latitude: 85.0)
                try! TileCoords.validate(latitude: -85.0)
                try! TileCoords.validate(longitude: -180)
                try! TileCoords.validate(longitude: 179.99)
                
                expect { try TileCoords.validate(latitude: 86.0)}.to(throwError())
                expect { try TileCoords.validate(latitude: -86)}.to(throwError())
                
                expect { try TileCoords.validate(longitude: 180.0)}.to(throwError())
                expect { try TileCoords.validate(longitude: -180.1)}.to(throwError())
            }
            
            it("can calculate tileX and tileY corner cases") {
                
                // These are the max values
                // https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y
                let y_north1 = try! TileCoords.latitudeToTileY(latitude: 85.0511, zoom: zoom)
                let y_south1 = try! TileCoords.latitudeToTileY(latitude: -85.0511, zoom: zoom)
                expect(y_north1).to(equal(0))
                expect(y_south1).to(equal(1023)) // 2^10 -1
                
                let x_west1 = try! TileCoords.longitudeToTileX(longitude: -180.0, zoom: 10)
                let x_east1 = try! TileCoords.longitudeToTileX(longitude: +179.99, zoom: 10)
                expect(x_west1).to(equal(0))
                expect(x_east1).to(equal(1023))
                
                expect { try TileCoords.latitudeToTileY(latitude: -85.0512, zoom: zoom)}.to(throwError())
                expect { try TileCoords.longitudeToTileX(longitude: 180.0, zoom: zoom)}.to(throwError())
                
            }
            
        }
    }
}
