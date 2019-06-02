//
//  DiskCacheSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 06/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import MapCache

class DiskCacheSpecs: QuickSpec {
    override func spec() {
        
        describe("DiskCache initialization") {
            it("can create the cache folder") {
                let diskCache = DiskCache(cacheName: "path")
                var isDirectory : ObjCBool = false
                print(diskCache.folderURL)
                let exists = FileManager.default.fileExists(atPath: diskCache.path, isDirectory: &isDirectory)
                expect(exists) == true
                expect(isDirectory.boolValue) == true
            }
            
            afterEach() {
                let diskCache = DiskCache(cacheName: "path")
                do {
                    try FileManager.default.removeItem(at: diskCache.folderURL)
                } catch {
                    print ("ERROR removing DiskCache folder")
                }
                let exists = FileManager.default.fileExists(atPath: diskCache.path)
                expect(exists) == false
            }
        }
        describe("a DiskCache") {
            var diskCache: DiskCache!
            
            beforeEach {
                diskCache = DiskCache(cacheName: "path2")
            }
            
            it("can add a file") {
               // expect(2) == 3
            }
            
            it("can add a file to the cache") {
                //expect(2) == 3
            }
            
            it("can find a file that is in the cache") {
                //expect("number") == "string"
            }
            
            it("cannot find a file that is not in the cache") {
                //expect("time").toEventually( equal("time2") )
            }
            
            it("can remove the file from the cache") {
                //expect("time").toEventually( equal("time2") )
            }
            
            it("can get disk usage from the cache") {
                //expect("time").toEventually( equal("time2") )
            }
            
            it("can get the number of items from the cache") {
               // expect("time").toEventually( equal("time2") )
            }
            
            context("these will pass") {
                
                it("can do maths") {
                   // expect(23) == 24
                }
                
                it("can read") {
                    //expect("🐮") == "🐮 "
                }
                
                it("will eventually pass") {
                    var time = "passing"
                    
                    DispatchQueue.main.async {
                        time = "done"
                    }
                    
                    waitUntil { done in
                        Thread.sleep(forTimeInterval: 0.5)
                        //expect(time) == "done"
                        
                        done()
                    }
                }
            }
        }
    }
}
