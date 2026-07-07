//
//  MapCacheTests.swift
//  MapCache_Tests
//
//  Created by merlos on 23/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
// https://github.com/Quick/Quick

import Foundation
import Quick
import Nimble
import MapCache
import MapKit
import OHHTTPStubs
import OHHTTPStubsSwift

class MapCacheTests: QuickSpec {
    
    override func spec() {
        beforeSuite {
            stub(condition: isHost("localhost")) { request in
                let stubData = request.url?.description.data(using: String.Encoding.utf8)
              return HTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
            }
            stub(condition: isHost("brokenhost")) { request in
                let stubData = request.url?.description.data(using: String.Encoding.utf8)
              return HTTPStubsResponse(data: stubData!, statusCode:404, headers:nil)
            }
            stub(condition: isHost("etaghost-store")) { request in
                let stubData = "tile-data".data(using: .utf8)
                return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: ["ETag": "abc123"])
            }
            stub(condition: isHost("etaghost-header")) { request in
                let stubData = "data".data(using: .utf8)
                return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
            }
            stub(condition: isHost("etaghost-304")) { request in
                return HTTPStubsResponse(data: Data(), statusCode: 304, headers: nil)
            }
            stub(condition: isHost("etaghost-orphan")) { request in
                if request.value(forHTTPHeaderField: "If-None-Match") != nil {
                    return HTTPStubsResponse(data: Data(), statusCode: 304, headers: nil)
                }
                let stubData = "fresh-data".data(using: .utf8)
                return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: ["ETag": "new-etag"])
            }
        }
        
        afterSuite {
        HTTPStubs.removeAllStubs()    
        }
            
        describe("MapCache") {
            let urlTemplate = "https://localhost/{s}/{x}/{y}/{z}"
            var config = MapCacheConfig(withUrlTemplate: urlTemplate)
            config.subdomains = ["ok"]
            let cache = MapCache(withConfig: config)
            let path = MKTileOverlayPath(x: 1, y: 2, z: 3, contentScaleFactor: 1.0)
            
            it("reports fileSize via diskCache") {
                // createa a new empty cache
                let sizeName = "fileSizeTest_\(Int.random(in: 1..<100000000))"
                var sizeConfig = MapCacheConfig(withUrlTemplate: urlTemplate)
                sizeConfig.cacheName = sizeName
                sizeConfig.subdomains = ["ok"]
                let sizeCache = MapCache(withConfig: sizeConfig)
                defer { sizeCache.diskCache.removeCache() }
                // check is empty
                expect(sizeCache.fileSize).toEventually(equal(0))
                // Add 10 bytes of data
                let data = "1234567890".data(using: .utf8)!
                sizeCache.diskCache.setDataSync(data, forKey: "test")
                // check it was added
                expect(sizeCache.fileSize).toEventually(equal(10))
                expect(sizeCache.fileSize).to(equal(sizeCache.diskCache.fileSize))
            }
            
            it("reports diskSize via diskCache") {
                expect(cache.diskSize).to(equal(cache.diskCache.diskSize))
            }
            
            it("can create the tile url") {
                let url = cache.url(forTilePath: path)
                expect(url.absoluteString) == "https://localhost/ok/1/2/3"
            }
            
            it("can generate the key for a path") {
                let key = cache.cacheKey(forPath: path)
                expect(key) == "\(urlTemplate)-1-2-3"
            }
            
            it("can fetch tile from server") {
                cache.fetchTileFromServer(
                    at: path,
                    failure: {error in expect(false) == true},
                    success: {data in expect(String(data: data, encoding: String.Encoding.utf8)) == cache.url(forTilePath: path).description} )
            }
            
            it("can return error on fetch") {
                let urlTemplate2 = "http://brokenhost/notworking"
                let config2 = MapCacheConfig(withUrlTemplate: urlTemplate2)
                let cache2 = MapCache(withConfig: config2)
                
                cache2.fetchTileFromServer(
                    at: path,
                    failure: {error in expect(true) == true},
                    success: {data in expect(true) == false} )
            }
        }
        
        describe("ETag caching") {
            func makeCache(host: String) -> (cache: MapCache, path: MKTileOverlayPath, key: String) {
                let urlTemplate = "https://\(host)/{s}/{x}/{y}/{z}"
                var config = MapCacheConfig(withUrlTemplate: urlTemplate)
                config.subdomains = ["ok"]
                let cache = MapCache(withConfig: config)
                let path = MKTileOverlayPath(x: 1, y: 2, z: 3, contentScaleFactor: 1.0)
                let key = cache.cacheKey(forPath: path)
                return (cache, path, key)
            }

            let (cache, path, key) = makeCache(host: "etaghost-store")

            it("has an etagCache") {
                expect(cache.etagCache).toNot(beNil())
                expect(cache.etagCache).to(beAKindOf(DiskCache.self))
            }

            it("saves ETag from 200 response") {
                waitUntil { done in
                    cache.fetchTileFromServer(
                        at: path,
                        failure: { error in
                            expect(error).to(beNil())
                            done()
                        },
                        success: { _ in
                            var etagResult: String?
                            cache.etagCache.fetchDataSync(forKey: key,
                                failure: nil,
                                success: { etagData in
                                    etagResult = String(data: etagData, encoding: .utf8)
                                })
                            expect(etagResult) == "abc123"
                            done()
                        })
                }
            }

            it("sends If-None-Match when ETag is cached") {
                let (headerCache, headerPath, headerKey) = makeCache(host: "etaghost-header")
                let expectedEtag = "xyz"

                var capturedIfNoneMatch: String?
                stub(condition: isHost("etaghost-header")) { request in
                    capturedIfNoneMatch = request.value(forHTTPHeaderField: "If-None-Match")
                    let stubData = "data".data(using: .utf8)
                    return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
                }

                headerCache.etagCache.setDataSync(expectedEtag.data(using: .utf8)!, forKey: headerKey)

                waitUntil { done in
                    headerCache.fetchTileFromServer(
                        at: headerPath,
                        failure: { _ in
                            expect(capturedIfNoneMatch) == expectedEtag
                            done()
                        },
                        success: { _ in
                            expect(capturedIfNoneMatch) == expectedEtag
                            done()
                        })
                }
            }

            it("returns cached data on 304") {
                let (localCache, localPath, localKey) = makeCache(host: "etaghost-304")

                let cachedTileData = "cached-tile-content".data(using: .utf8)!
                localCache.diskCache.setDataSync(cachedTileData, forKey: localKey)
                localCache.etagCache.setDataSync("etag-304".data(using: .utf8)!, forKey: localKey)

                waitUntil { done in
                    localCache.fetchTileFromServer(
                        at: localPath,
                        failure: { _ in
                            expect(false).to(beTrue())
                            done()
                        },
                        success: { data in
                            expect(data) == cachedTileData
                            done()
                        })
                }
            }

            it("re-fetches on 304 when cached data is missing") {
                let (localCache, localPath, localKey) = makeCache(host: "etaghost-orphan")

                localCache.etagCache.setDataSync("orphan-etag".data(using: .utf8)!, forKey: localKey)

                waitUntil { done in
                    localCache.fetchTileFromServer(
                        at: localPath,
                        failure: { _ in
                            expect(false).to(beTrue())
                            done()
                        },
                        success: { data in
                            expect(String(data: data, encoding: .utf8)) == "fresh-data"
                            var newEtag: String?
                            localCache.etagCache.fetchDataSync(forKey: localKey,
                                failure: nil,
                                success: { etagData in
                                    newEtag = String(data: etagData, encoding: .utf8)
                                })
                            expect(newEtag) == "new-etag"
                            done()
                        })
                }
            }

            it("clear removes both caches") {
                let (localCache, _, localKey) = makeCache(host: "localhost")

                localCache.diskCache.setDataSync("some-data".data(using: .utf8)!, forKey: localKey)
                localCache.etagCache.setDataSync("some-etag".data(using: .utf8)!, forKey: localKey)

                waitUntil { done in
                    localCache.clear {
                        var diskData: Data?
                        localCache.diskCache.fetchDataSync(forKey: localKey,
                            failure: nil,
                            success: { data in diskData = data })
                        expect(diskData).to(beNil())

                        var etagData: Data?
                        localCache.etagCache.fetchDataSync(forKey: localKey,
                            failure: nil,
                            success: { data in etagData = data })
                        expect(etagData).to(beNil())

                        done()
                    }
                }
            }
        }
    }
}
