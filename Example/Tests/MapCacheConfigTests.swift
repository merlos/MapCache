//
//  MapCacheConfigTests.swift
//  MapCache_Tests
//
//  Created by merlos on 10/11/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.

import Quick
import Nimble
import MapCache

class MapCacheConfigTests: QuickSpec {
   override func spec() {
         describe("MapCacheConfig") {
             
             it("can do round robin") {
                var cache = MapCacheConfig()
                // because the +1 is done before returning value, it starts
                // with the second
                expect(cache.roundRobinSubdomain()).to(equal("b"))
                expect(cache.roundRobinSubdomain()).to(equal("c"))
                expect(cache.roundRobinSubdomain()).to(equal("a"))
                expect(cache.roundRobinSubdomain()).to(equal("b"))
             }
             
             it("can do round robin without subdomains") {
               var cache = MapCacheConfig()
                cache.subdomains = []
                expect(cache.roundRobinSubdomain()).to(beNil())
             }
        }
    }
}
