//
//  RegionDownloaderSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 25/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import MapKit
@testable import MapCache

/// Mock of MapCache
///
/// - SeeAlso: https://medium.com/@johnsundell/mocking-in-swift-56a913ee7484
class MapCacheMock : MapCacheProtocol {
    
    /// It is not being used but It is required by the protocol.
    func url(forTilePath path: MKTileOverlayPath) -> URL {
        return URL(fileURLWithPath: "http://mapcache.github.io/")
    }
    
    public var config: MapCacheConfig = MapCacheConfig()
    
    enum ResultType {
        case error
        case data
        case mixed
    }
    
    public var counter: UInt = 0
    
    /// If ResultType= .mixed the function loadTile will return an error every errorEvery
    /// For example errorEvery=5 it will return an error every 5 tile loads (counter % 5)
    /// Default 5.
    public var errorEvery: UInt = 5
    
    /// What kind of result shall loadTile return error or data?
    public var resultType: ResultType = .data
    
    /// Mock data to be returned in loadTile
    public var data: Data = "1234567890".data(using: .utf8)!
    
    
    public var error: NSError = NSError(domain: "MockError", code: 100, userInfo: [:])
    
    func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        counter += 1
        switch(resultType) {
        case .mixed:
            if (counter % errorEvery) == 0 {
                result(nil, error)
            }
            result(data, nil)
        case .data:
            result(data, nil)
            
        case .error:
            result(nil, error)
        }
    }
}

class DelegateTest : RegionDownloaderDelegate {
    
    public var finished = false
    
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double) {
        print("didDownloadPercentage")
    }
    
    func regionDownloader(_ regionDownloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber) {
        print("FinishDonwload")
        finished = true
    }
}

class RegionDownloaderSpecs: QuickSpec {
    override func spec() {
        describe("RegionDownloader") {
            
            let config : MapCacheConfig = MapCacheConfig()
            let mapCache : MapCache = MapCache(withConfig: config)

            let topLeft = TileCoords(latitude: 20.0, longitude: 10.0, zoom: 10)!
            let bottomRight = TileCoords(latitude: 10.0, longitude: 20.0, zoom: 10)!
            let region = TileCoordsRegion(topLeft: topLeft, bottomRight: bottomRight)!
            
            
            it("inits with TileCoords") {
                let downloader = RegionDownloader(forRegion: region, mapCache: mapCache)
                //Check that initialization is there
                expect(downloader.totalTilesToDownload).to(equal(region.count))
                expect(downloader.downloadedTiles).to(equal(0))
                expect(downloader.successfulTileDownloads).to(equal(0))
                expect(downloader.failedTileDownloads).to(equal(0))
            }
            
            it("counts downloaded tiles ok") {
                let mapCacheMock = MapCacheMock()
                let downloader = RegionDownloader(forRegion: region, mapCache: mapCacheMock)
                let delegate = DelegateTest()
                downloader.delegate = delegate
                downloader.start()
                expect(delegate.finished).toEventually(beTrue(), timeout: 10)

            }
        }
    }
}
