//
//  TileRangeSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 14/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import MapCache

class TileRangeSpecs: QuickSpec {
    override func spec() {
        describe("TileRange") {
            it("inits") {
                let tR = TileRange(zoom: 10, minTileX: 15, maxTileX: 20, minTileY: 25, maxTileY: 30)
                expect(tR).notTo(beNil())
                
                expect(tR.zoom).to(equal(10))
                expect(tR.minTileX).to(equal(15))
                expect(tR.maxTileX).to(equal(20))
                expect(tR.minTileY).to(equal(25))
                expect(tR.maxTileY).to(equal(30))
            }
            
            it("can get calculated values") {
                let tR = TileRange(zoom: 10, minTileX: 15, maxTileX: 20, minTileY: 30, maxTileY: 41)
                expect(tR.diffX).to(equal(5))
                expect(tR.diffY).to(equal(11))
                expect(tR.columns).to(equal(6))
                expect(tR.rows).to(equal(12))
                expect(tR.count).to(equal(6*12))
            }
            
            it("can iterate") {
                let tR = TileRange(zoom: 10, minTileX: 15, maxTileX: 20, minTileY: 25, maxTileY: 30)
                var count = 0
                for _ in tR {
                    count += 1
                }
                expect(tR.count == count).to(beTrue())
            }
            
            it("can iterate with one column or row") {
                // 1 Column
                let tROneCol = TileRange(zoom: 10, minTileX: 20, maxTileX: 20, minTileY: 25, maxTileY: 30)
                // 1 Row
                let tROneRow = TileRange(zoom: 10, minTileX: 10, maxTileX: 19, minTileY: 25, maxTileY: 25)
                
                var countOneCol = 0
                for _ in tROneCol {
                    countOneCol += 1
                }
                expect(countOneCol).to(equal(1*6))
                expect(tROneCol.columns).to(equal(1))
                expect(tROneCol.count).to(equal(1*6))
                expect(tROneRow.count).to(equal(1*10))
                
            }
        }
    }
}
