//
//  DiskCacheSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 06/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import MapCache

class DiskCacheSpecs: QuickSpec {
    override func spec() {
        
        func removeCache(cacheName: String) {
            let diskCache = DiskCache(withName: cacheName)
            do {
                try FileManager.default.removeItem(at: diskCache.folderURL)
            } catch {
                print ("ERROR removing DiskCache folder")
            }
            let exists = FileManager.default.fileExists(atPath: diskCache.path)
            expect(exists) == false
        }
        
        describe("DiskCache initialization") {
            it("can create the cache folder") {
                let diskCache = DiskCache(withName: "path")
                var isDirectory : ObjCBool = false
                print(diskCache.folderURL)
                let exists = FileManager.default.fileExists(atPath: diskCache.path, isDirectory: &isDirectory)
                expect(exists) == true
                expect(isDirectory.boolValue) == true
            }
            
            afterEach() {
                let diskCache = DiskCache(withName: "path")
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
            
            let cacheName = "path2"
            var diskCache: DiskCache!
            let filename1 = "http://www."
            let data1 = "1234567890".data(using: .utf8)
            
            // Set a long file name
            var longFileName: String = "1234567890"
            
            for i in 0...NAME_MAX {
                longFileName.append(String(i))
            }
            let dataLongFile = "1234567890".data(using: .utf8)
            
            beforeEach {
                diskCache = DiskCache(withName: cacheName)
            }
            
            afterEach {
                removeCache(cacheName: cacheName)
            }
            
            it("can add a file") {
                let data = data1
                let filename = filename1
                
                diskCache.setData(data!, forKey: filename)
                let filePath = diskCache.folderURL.appendingPathComponent(filename.escapedFilename()).path
                //Thread.sleep(forTimeInterval: 0.3)
                //expect(FileManager.default.fileExists(atPath: filePath)) == true
                expect(FileManager.default.fileExists(atPath: filePath)).toEventually(equal(true))
            }
            
            it("can add a file with a very long name") {
                let data = dataLongFile
                let filename = longFileName
                
                diskCache.setData(data!, forKey: filename)
                let filePath = diskCache.folderURL.appendingPathComponent(filename.MD5Filename()).path
                expect(FileManager.default.fileExists(atPath: filePath)).toEventually(equal(true))
            }
            
            it("keeps track of its size") {
                let size = diskCache.calculateSize()
                expect(size) == 0
                diskCache.setDataSync(data1!, forKey: filename1)
                expect(diskCache.size).toEventually(equal(10))
    
            }
            
            it("can find a file that is in the cache") {
                diskCache.setData(data1!, forKey: filename1)
                expect(diskCache.size).toEventually(equal(10))
                diskCache.fetchData(forKey: filename1, failure: {error in return}, success: {
                    expect($0) == data1
                })
                
            }
            
            it("cannot find a file that is not in the cache") {
                diskCache.fetchData(forKey: "filename1", failure: { error in
                    guard let error = error as NSError? else {
                        return
                    }
                    expect(error.code).to(equal(NSFileReadNoSuchFileError))
                    return
                }, success: {
                    expect($0) == data1
                })
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
