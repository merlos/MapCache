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
            
            let lat: Double = 3.2
            let lon: Double = 2.2
            
            it("can initialize with lat and long") {
                do {
                    let tileCoords = try TileCoords(latitude: lat, longitude: lon, zoom: 10)
                    print(tileCoords.latitude)
                    print(tileCoords.longitude)
                    print(tileCoords.tileX)
                    print(tileCoords.tileY)
                } catch {
                    
                }
            }
        }
    }
}
