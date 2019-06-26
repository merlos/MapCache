//
//  TileRegionSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 15/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import MapCache

class TileRegionSpecs: QuickSpec {
    override func spec() {
        describe("TileRegion") {
            it("inits with TileCoords") {
                let topLeft = TileCoords(tileX: 100, tileY: 100, zoom: 10)
                let bottomRight = TileCoords(tileX: 200, tileY: 150, zoom: 10)
                let tileCoordsRegion = TileCoordsRegion(topLeft: topLeft!, bottomRight: bottomRight!)
                expect(tileCoordsRegion).notTo(beNil())
                expect(tileCoordsRegion?.topLeft).to(be(topLeft))
                expect(tileCoordsRegion?.bottomRight).to(be(bottomRight))
                expect(tileCoordsRegion?.topLeft.tileX).to(equal(100))
                expect(tileCoordsRegion?.bottomRight.tileY).to(equal(150))

            }
            
            it("inits with coordinates") {
                let tileCoordsRegion = TileCoordsRegion(
                    topLeftLatitude: 80.0,
                    topLeftLongitude: -100.0,
                    bottomRightLatitude: -80.0,
                    bottomRightLongitude: 100.0,
                    minZoom: 10,
                    maxZoom: 19)
                expect(tileCoordsRegion?.topLeft.latitude).to(beCloseTo(80.0))
                expect(tileCoordsRegion?.topLeft.longitude).to(beCloseTo(-100.0))
                
                expect(tileCoordsRegion?.bottomRight.latitude).to(beCloseTo(-80.0))
                expect(tileCoordsRegion?.bottomRight.longitude).to(beCloseTo(100.0))
            }
        }
        describe("TileRegion of a not splitted region") {
            // (lat 85.0, lon -100.0) zoom 10 ==> (x= 227, y= 1)
            // (lat -85.0,lon +100.0) zoom 10 ==> (x= 796, y= 1022)
            let topLeft = TileCoords(latitude: 85.0, longitude: -100.0, zoom: 10)!
            let bottomRight = TileCoords(latitude: -85.0, longitude: 100.0, zoom: 19)!
            let tileCoordsRegion = TileCoordsRegion(topLeft: topLeft,
                                                    bottomRight: bottomRight)!
            
            //(lat 85.0, lon 100.0) zoom 10 ==> (x=796, y= 1)
            //(lat -85.0,lon -100.0) zoom 10 ==> (x= 227, y= 1022)
            let topLeft2 = TileCoords(latitude: 85.0, longitude: 100.0, zoom: 10)!
            let bottomRight2 = TileCoords(latitude: -85.0, longitude: -100.0, zoom: 19)!
            let tileCoordsRegion2 = TileCoordsRegion(topLeft: topLeft2,
                                                     bottomRight: bottomRight2)
            it("can provide the zoom range") {
                expect(tileCoordsRegion.zoomRange.min).to(equal(10))
                expect(tileCoordsRegion.zoomRange.max).to(equal(19))
            }
            
            it("can return the tile ranges for a particular zoom") {
                let tileRanges = tileCoordsRegion.tileRanges(forZoom: 10)
                expect(tileRanges!.count).to(equal(1))
                expect(tileRanges![0].columns).to(equal(796 - 227 + 1))
                expect(tileRanges![0].rows).to(equal(1022 - 1 + 1))
            }
            
            it("can return the tile ranges for a particular zoom that traverses end of map") {
                // TileCoordsRegion2:
                //      topleft = (796,1)
                //      bottomRight = (227, 1022)
                //
                // Because bottom right is after the end of the map we have two regions
                // one will have S1 number of columns and the other S2 number of columns.
                // In both cases the number of rows is 1022.
                //
                //   0     (796,1)    1023 (end of map)
                //   +--------*-----------+--------------
                //   |        |<--------->|
                //   |             S1     |  S2
                //   |                    |<---->|
                //   +--------------------+------*
                //                        ^     (227,1022)
                //                        |
                //                        start of map
                expect(tileCoordsRegion2).notTo(beNil())
                let tileRanges = tileCoordsRegion2?.tileRanges(forZoom: 10)
                expect(tileRanges!.count).to(equal(2))
                // S1 = tileRanges[0].columns
                expect(tileRanges![0].columns).to(equal(1023-796 + 1))
                expect(tileRanges![0].rows).to(equal(1022 - 1 + 1))
                // S2 = tileRanges[1].columns
                expect(tileRanges![0].columns).to(equal(227 + 1))
                expect(tileRanges![0].rows).to(equal(1022 - 1 + 1))
            }
            
            
            it("can return region TileRages for all zoom levels") {
                let tileRanges = tileCoordsRegion.tileRanges()
                expect(tileRanges?.count).to(equal(10)) // 10 = number of zoom levels
            }
            
            
            it("can count the number of tiles for a particular zoom level") {
                let counted = tileCoordsRegion.count(forZoom: 10)
                // It should be columns x rows
                // cols = 796 - 227 + 1 = 570
                // rows = 1022
                // 570 x 1022 = 582 540
                expect(counted).to(equal(582540))
            }
            
            it("can count the number of tiles for all zoom levels") {
                let tL = TileCoords(latitude:TileCoords.maxLatitude,
                                    longitude: TileCoords.minLongitude,
                                    zoom: TileCoords.minZoom)
                let bR = TileCoords(latitude: TileCoords.minLatitude,
                                    longitude: TileCoords.maxLongitude,
                                    zoom: 5)
                let world = TileCoordsRegion(topLeft: tL!, bottomRight: bR!)!
                let counted = world.count
                                 //   0     1     2     3    4        5
                let sum: TileNumber = 1 + 4 + 16 + 64 + 256 + 1024
                print("+++++++++++++ \(counted)")
                expect(sum == counted).to(beTrue())
            }
            
            it("can count the whole world") {
                let tL = TileCoords(latitude:TileCoords.maxLatitude,
                                longitude: TileCoords.minLongitude,
                                zoom: TileCoords.minZoom)
                let bR = TileCoords(latitude: TileCoords.minLatitude,
                                longitude: TileCoords.maxLongitude,
                                zoom: TileCoords.maxZoom)
                let world = TileCoordsRegion(topLeft: tL!, bottomRight: bR!)!
                // count = 1 + 4 + 16 + 64 + ... 4^zoom ... 4^19
                expect(world.count).to(equal(366503875925))
                //print("wwwwwwwwwwwwww \(counted)")
            }
        }
    }
}
