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

/// Unit Testing for `DiskCache`
class DiskCacheSpecs: QuickSpec {
    override func spec() {
        
        /// Removes the cache folder
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
                //print(diskCache.folderURL)
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
            
            let cacheBaseName = "cache"
            var cacheName: String = ""
            var diskCache: DiskCache!
            let filename1 = "http://www."
            let data1 = "1234567890".data(using: .utf8) // size = 10
            
            // Set a long file name
            var longFileName: String = "1234567890"
            
            for i in 0...NAME_MAX {
                longFileName.append(String(i))
            }
            let dataLongFile = "1234567890".data(using: .utf8)
            
            beforeEach {
                cacheName = cacheBaseName + String(Int.random(in: 1..<100000000))
                diskCache = DiskCache(withName: cacheName)
            }
            
            afterEach {
                diskCache.removeCache()
                let exists = FileManager.default.fileExists(atPath: diskCache.path)
                expect(exists) == false
            }
            
            it("can add a file") {
                let data = data1
                let filename = filename1
                diskCache.setData(data!, forKey: filename)
                let filePath = diskCache.folderURL.appendingPathComponent(filename.toMD5()).path
                expect(FileManager.default.fileExists(atPath: filePath)).toEventually(equal(true))
            }
            
            it("can add a file with a very long name") {
                let data = dataLongFile
                let filename = longFileName
                
                diskCache.setData(data!, forKey: filename)
                let filePath = diskCache.folderURL.appendingPathComponent(filename.MD5Filename()).path
                expect(FileManager.default.fileExists(atPath: filePath)).toEventually(equal(true))
            }
            
            it("keeps track of its disk size") {
                let diskSize = diskCache.calculateDiskSize()
                expect(diskSize) == 0
                expect(diskCache.diskSize).to(equal(0))
                diskCache.setDataSync(data1!, forKey: filename1)
                // Note that 1 file ad minimum uses 4096 bytes in disk which is the
                // block size.
                // The actual content is only 10 bytes.
                expect(diskCache.calculateDiskSize()).toEventually(equal(4096))
            }
            
            it("keeps track of its file size") {
                expect(diskCache.fileSize).toEventually(equal(0))
                diskCache.setDataSync(data1!, forKey: filename1)
                expect(diskCache.fileSize).toEventually(equal(10))
            }
            
            it("can find a file that is in the cache") {
                expect(diskCache.diskSize).to(equal(0))
                diskCache.setDataSync(data1!, forKey: filename1)
                expect(diskCache.diskSize).to(equal(4096))
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
            
            //it("can handle weird names2") {
            //    let diskCache2 = DiskCache(withName: "weird")
            //   let weird1 = "ºª|!@#·$%&¬/()= ?'¿¡^`[]+*¨´{}ç;,.-<>€"
            //    print("weird: \(diskCache2.path(forKey: weird1))")
            //    diskCache2.setData(data1!, forKey: weird1)
            //}
            
            it("can add files with weird names") {
                let weird1 = "ºª|!@#·$%&¬/()= ?'¿¡^`[]+*¨´{}ç;,.-<>€"
                //print("weird: \(diskCache.path(forKey: weird1))")
                expect(diskCache.diskSize).to(equal(0))
                diskCache.setDataSync(data1!, forKey: weird1)
                let filePath = diskCache.path(forKey: weird1)
                expect(FileManager.default.fileExists(atPath: filePath)).to(equal(true))
               
                expect(diskCache.calculateDiskSize()).to(equal(4096))
                sleep(2)
                diskCache.fetchData(forKey: weird1, failure: { error in
                    guard let error = error as NSError? else {
                        expect(1) > 2
                        return
                    }
                    expect(error.code).toNot(equal(NSFileReadNoSuchFileError))
                    return
                }, success: {
                    expect($0) == data1
                })
                
            }
            
            it("can remove the file from the cache") {
                // add the file
                expect(diskCache.diskSize).to(equal(0))
                diskCache.setDataSync(data1!, forKey: filename1)
                expect(diskCache.diskSize).to(equal(4096))
                // remove the file
                diskCache.removeData(withKey: filename1)
                sleep(1)
                expect(diskCache.diskSize).toEventually(equal(0))
                diskCache.fetchData(forKey: filename1, failure: { error in
                    guard let error = error as NSError? else {
                        expect(1) > 2
                        return
                    }
                    expect(error.code).to(equal(NSFileReadNoSuchFileError))
                    return
                }, success: {
                    // if the test goes right it should never come here
                    expect($0.isEmpty) == true //make it fail
                })
            }
            
            it("can remove all items from the cache") {
                diskCache.setDataSync(data1!, forKey: filename1)
                diskCache.setDataSync(dataLongFile!, forKey: longFileName)
                expect(diskCache.diskSize).to(equal(8192))
                diskCache.removeAllData({})
                expect(diskCache.calculateDiskSize()).toEventually(equal(0))
            }
            
        }
    }
}
