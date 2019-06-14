//
//  ZoomRangeSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 13/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import MapCache

class ZoomRangeSpecs: QuickSpec {
    override func spec() {
        describe("ZoomRange") {
            it("inits with valid zooms") {
                let z1 = ZoomRange(1,2)
                expect(z1?.min).to(equal(1))
                expect(z1?.max).to(equal(2))
                
                let z2 = ZoomRange(2,1)
                expect(z2?.min).to(equal(1))
                expect(z2?.max).to(equal(2))
            }
            
            it("does not init with invalid zooms") {
                let z1 = ZoomRange(20,2)
                expect(z1).to(beNil())
                
                let z2 = ZoomRange(2,20)
                expect(z2).to(beNil())
            }
            
            it("provides the difference of zooms") {
                let z1 = ZoomRange(10,2)
                expect(z1?.diffZoom).to(equal(8))
            }
            
            it("counts the number of zooms") {
                let z1 = ZoomRange(1,1)
                expect(z1?.count).to(equal(1))
                let z2 = ZoomRange(0,19)
                expect(z2?.count).to(equal(20))
            }
            
            it ("can be converted to array") {
                let z1Arr = ZoomRange(0,5)?.toArray()
                expect(z1Arr?.count).to(equal(6))
                expect(z1Arr?[1]).to(equal(1))
            }
            
        }
    }
}
