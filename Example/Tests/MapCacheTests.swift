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
import MapKit
import OHHTTPStubs

class MapCacheTests: QuickSpec {
    
    override func spec() {
        beforeSuite {
            // This stub returns as data the URL of the request
            stub(condition: isHost("localhost")) { request in
                let stubData = request.url?.description.data(using: .utf8)
              return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
            }
            // This stub returns a 404 error
            stub(condition: isHost("brokenhost")) { request in
                let stubData = request.url?.description.data(using: .utf8)
              return OHHTTPStubsResponse(data: stubData!, statusCode:404, headers:nil)
            }
        }
        
        afterSuite {
        OHHTTPStubs.removeAllStubs()    
        }
            
        describe("MapCache") {
            let urlTemplate = "https://localhost/{s}/{x}/{y}/{z}"
            var config = MapCacheConfig(withUrlTemplate: urlTemplate)
            config.subdomains = ["ok"]
            let cache = MapCache(withConfig: config)
            let path = MKTileOverlayPath(x: 1, y: 2, z: 3, contentScaleFactor: 1.0)
            
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
                    success: {data in expect(String(data: data, encoding: .utf8)) == cache.url(forTilePath: path).description} )
            }
            
            it("can return error on fetch") {
                //Set a template url that returns error (in this case does not use https)
                let urlTemplate2 = "http://brokenhost/notworking"
                let config2 = MapCacheConfig(withUrlTemplate: urlTemplate2)
                let cache2 = MapCache(withConfig: config2)
                
                cache2.fetchTileFromServer(
                    at: path,
                    failure: {error in expect(true) == true},
                    success: {data in expect(true) == false} )
            }
              
        }
    }
}
