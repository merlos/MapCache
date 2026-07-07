//
//  RegionDownloaderDelegateSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 07/07/2026.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import MapKit
@testable import MapCache

class DelegateTest : RegionDownloaderDelegate {

    public var finished = false
    public var startCallCount = 0
    public var startTotalTiles: TileNumber = 0
    public var successCallCount = 0
    public var successCoords: [TileCoords] = []
    public var failureCallCount = 0
    public var failureCoords: [TileCoords] = []

    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double) {
        print("didDownloadPercentage")
    }

    func regionDownloader(_ regionDownloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber) {
        print("FinishDonwload")
        finished = true
    }

    func regionDownloader(_ regionDownloader: RegionDownloader, willStartDownloading totalTiles: TileNumber, region: TileCoordsRegion, mapCache: MapCacheProtocol) {
        startCallCount += 1
        startTotalTiles = totalTiles
    }

    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadTileAt tileCoords: TileCoords, dataSize: Int) {
        successCallCount += 1
        successCoords.append(tileCoords)
    }

    func regionDownloader(_ regionDownloader: RegionDownloader, didFailToDownloadTileAt tileCoords: TileCoords, error: Error) {
        failureCallCount += 1
        failureCoords.append(tileCoords)
    }
}

class RegionDownloaderDelegateSpecs: QuickSpec {
    override func spec() {
        describe("RegionDownloaderDelegate") {

            let mapCacheMock = MapCacheMock()
            let topLeft = TileCoords(latitude: 20.0, longitude: 10.0, zoom: 10)!
            let bottomRight = TileCoords(latitude: 10.0, longitude: 20.0, zoom: 10)!
            let region = TileCoordsRegion(topLeft: topLeft, bottomRight: bottomRight)!

            it("calls willStartDownloading before starting") {
                let downloader = RegionDownloader(forRegion: region, mapCache: mapCacheMock)
                let delegate = DelegateTest()
                downloader.delegate = delegate
                downloader.start()
                expect(delegate.startCallCount).toEventually(equal(1), timeout: .seconds(10))
                expect(delegate.startTotalTiles).to(equal(region.count))
            }

            it("calls didDownloadTileAt for each tile on success") {
                mapCacheMock.resultType = .data
                mapCacheMock.counter = 0
                let downloader = RegionDownloader(forRegion: region, mapCache: mapCacheMock)
                let delegate = DelegateTest()
                downloader.delegate = delegate
                downloader.start()
                expect(delegate.finished).toEventually(beTrue(), timeout: .seconds(10))
                expect(delegate.successCallCount).to(equal(Int(region.count)))
                expect(delegate.failureCallCount).to(equal(0))
            }

            it("calls didFailToDownloadTileAt for each tile on error") {
                mapCacheMock.resultType = .error
                mapCacheMock.counter = 0
                let downloader = RegionDownloader(forRegion: region, mapCache: mapCacheMock)
                let delegate = DelegateTest()
                downloader.delegate = delegate
                downloader.start()
                expect(delegate.finished).toEventually(beTrue(), timeout: .seconds(10))
                expect(delegate.failureCallCount).to(equal(Int(region.count)))
                expect(delegate.successCallCount).to(equal(0))
            }

            it("passes correct tile zoom in success callbacks") {
                mapCacheMock.resultType = .data
                mapCacheMock.counter = 0
                let downloader = RegionDownloader(forRegion: region, mapCache: mapCacheMock)
                let delegate = DelegateTest()
                downloader.delegate = delegate
                downloader.start()
                expect(delegate.finished).toEventually(beTrue(), timeout: .seconds(10))
                expect(delegate.successCoords.first?.zoom).to(equal(10))
            }

            it("passes correct tile zoom in failure callbacks") {
                mapCacheMock.resultType = .error
                mapCacheMock.counter = 0
                let downloader = RegionDownloader(forRegion: region, mapCache: mapCacheMock)
                let delegate = DelegateTest()
                downloader.delegate = delegate
                downloader.start()
                expect(delegate.finished).toEventually(beTrue(), timeout: .seconds(10))
                expect(delegate.failureCoords.first?.zoom).to(equal(10))
            }
        }
    }
}
