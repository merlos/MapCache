//
//  MapCacheTests.swift
//  MapCache_Tests
//
//  Created by merlos on 23/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
// https://github.com/Quick/Quick

import Quick
import Nimble
import MapCache

class MapCacheTests: QuickSpec {
    override func spec() {
        describe("MapCache") {
            
            it("can do maths") {
                expect(2) == 2
            }
            
            it("can read") {
                //expect("number") == "string"
            }
            
            it("will eventually fail") {
                expect("time").toEventually( equal("time") )
            }
            
            context("these will pass") {
                
                it("can do maths") {
                    expect(23) == 23
                }
                
                it("can read") {
                    expect("🐮") == "🐮"
                }
                
                it("will eventually pass") {
                    var time = "passing"
                    
                    DispatchQueue.main.async {
                        time = "done"
                    }
                    
                    waitUntil { done in
                        Thread.sleep(forTimeInterval: 0.5)
                        expect(time) == "done"
                        
                        done()
                    }
                }
            }
        }
    }
}
