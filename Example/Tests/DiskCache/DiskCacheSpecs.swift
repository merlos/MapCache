//
//  DiskCacheSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 06/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import MapCache

/// Unit Testing for `DiskCache`

class DiskCacheSpecs: QuickSpec {

    override func spec() {
        // Increase the global timeout to 5 seconds:
        Nimble.AsyncDefaults.timeout = .seconds(5)
        // Slow the polling interval to 0.2 seconds:
        Nimble.AsyncDefaults.pollInterval = .milliseconds(200)

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
                try! FileManager.default.removeItem(at: DiskCache.defaultBaseURL())
                diskCache = DiskCache(withName: cacheName)
                expect(diskCache.diskSize).to(equal(0))
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
                expect(FileManager.default.fileExists(atPath: filePath)).toEventually(equal(true), timeout: .seconds(2))
            }
            
            it("keeps track of its disk size") {
                expect(diskCache.diskSize).to(equal(0))
                diskCache.setDataSync(data1!, forKey: filename1)
                // Note that 1 file ad minimum uses 4096 bytes in disk which is the
                // block size.
                // The actual content is only 10 bytes.
                expect(diskCache.diskSize).toEventually(equal(4096))
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
                
                var result: Data?
                diskCache.fetchDataSync(forKey: filename1, failure: nil, success: {
                    result = $0
                })

                expect(result).toEventually(equal(data1!), timeout: .seconds(2))
            }
            
            it("cannot find a file that is not in the cache") {
                var errorCode: Int?
                diskCache.fetchDataSync(forKey: "filename1", failure: { error in
                    errorCode = (error! as NSError).code
                }, success: { _ in })
                expect(errorCode).toEventually(equal(NSFileReadNoSuchFileError), timeout: .seconds(1))
            }
            
            it("can add files with weird names") {
                let weird1 = "ºª|!@#·$%&¬/()= ?'¿¡^`[]+*¨´{}ç;,.-<>€"
//                print("weird: \(diskCache.path(forKey: weird1))")
                expect(diskCache.diskSize).to(equal(0))
                diskCache.setDataSync(data1!, forKey: weird1)
                let filePath = diskCache.path(forKey: weird1)
                expect(FileManager.default.fileExists(atPath: filePath)).to(equal(true))
               
                expect(diskCache.diskSize).to(equal(4096))
                
                var result: Data?
                diskCache.fetchDataSync(forKey: weird1, failure: nil, success: {
                    result = $0
                })

                expect(result).toEventually(equal(data1!), timeout: .seconds(2))
            }
            
            it("can remove the file from the cache") {
                print("----------------------------")
                // add the file
                expect(diskCache.diskSize).to(equal(0))
                diskCache.setDataSync(data1!, forKey: filename1)
                expect(diskCache.diskSize).to(equal(4096))
                // remove the file
                diskCache.removeData(withKey: filename1)
                
                expect(diskCache.diskSize).toEventually(equal(0))
                
                var errorCode: Int?
                diskCache.fetchDataSync(forKey: filename1, failure: { error in
                    errorCode = (error! as NSError).code
                }, success: { _ in })
                expect(errorCode).toEventually(equal(NSFileReadNoSuchFileError))
            }
            
            it("can remove all items from the cache") {
                print("folder URL", diskCache.folderURL)
                expect(diskCache.diskSize).to(equal(0))
                diskCache.setDataSync(data1!, forKey: filename1)
                expect(diskCache.diskSize).to(equal(4096))
                diskCache.setDataSync(data1!, forKey: longFileName)
                expect(diskCache.diskSize).to(equal(8192))
                diskCache.removeAllData({})
                expect(diskCache.diskSize).toEventually(equal(0))
            }
            
        }
        
        describe("DiskCache with custom baseURL") {
            
            let customBaseName = "customBaseCache"
            var customBaseURL: URL!
            var customDiskCache: DiskCache!
            
            beforeEach {
                let tempDir = FileManager.default.temporaryDirectory
                customBaseURL = tempDir.appendingPathComponent("MapCacheTests_\(Int.random(in: 1..<100000000))", isDirectory: true)
                try? FileManager.default.removeItem(at: customBaseURL)
                customDiskCache = DiskCache(withName: customBaseName, baseURL: customBaseURL)
            }
            
            afterEach {
                customDiskCache.removeCache()
                try? FileManager.default.removeItem(at: customBaseURL)
            }
            
            it("stores data in the custom baseURL directory") {
                let expectedFolder = customBaseURL.appendingPathComponent(customBaseName, isDirectory: true)
                var isDir: ObjCBool = false
                let exists = FileManager.default.fileExists(atPath: expectedFolder.path, isDirectory: &isDir)
                expect(exists) == true
                expect(isDir.boolValue) == true
            }
            
            it("places folderURL under the custom baseURL") {
                let expected = customBaseURL.appendingPathComponent(customBaseName, isDirectory: true)
                expect(customDiskCache.folderURL.path).to(beginWith(expected.path))
            }
            
            it("can write and read data with custom baseURL") {
                let key = "customKey"
                let data = "customData".data(using: .utf8)!
                customDiskCache.setDataSync(data, forKey: key)
                
                var result: Data?
                customDiskCache.fetchDataSync(forKey: key, failure: nil, success: {
                    result = $0
                })
                expect(result).toEventually(equal(data))
            }
            
            it("is independent from caches with different baseURLs") {
                let key = "sharedKey"
                let data = "dataForCustom".data(using: .utf8)!
                customDiskCache.setDataSync(data, forKey: key)
                
                let defaultDiskCache = DiskCache(withName: customBaseName)
                defer { defaultDiskCache.removeCache() }
                
                var result: Data?
                defaultDiskCache.fetchDataSync(forKey: key, failure: { _ in }, success: {
                    result = $0
                })
                // The default cache should NOT have the data written to the custom cache
                expect(result).toEventually(beNil())
            }
        }
        
        describe("MapCache with custom baseURL") {
            it("creates disk caches under the custom baseURL") {
                let tempDir = FileManager.default.temporaryDirectory
                let customBase = tempDir.appendingPathComponent("MapCacheIntegration_\(Int.random(in: 1..<100000000))", isDirectory: true)
                try? FileManager.default.removeItem(at: customBase)
                defer { try? FileManager.default.removeItem(at: customBase) }
                
                var config = MapCacheConfig()
                config.cacheName = "IntegrationTest"
                config.baseURL = customBase
                let mapCache = MapCache(withConfig: config)
                defer {
                    mapCache.diskCache.removeCache()
                    mapCache.etagCache.removeCache()
                }
                
                let expectedDisk = customBase.appendingPathComponent("IntegrationTest", isDirectory: true)
                let expectedEtag = customBase.appendingPathComponent("IntegrationTest-etags", isDirectory: true)
                
                var isDir: ObjCBool = false
                expect(FileManager.default.fileExists(atPath: expectedDisk.path, isDirectory: &isDir)) == true
                expect(isDir.boolValue) == true
                
                expect(FileManager.default.fileExists(atPath: expectedEtag.path, isDirectory: &isDir)) == true
                expect(isDir.boolValue) == true
            }
        }
    }
}
