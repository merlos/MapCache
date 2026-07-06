//
//  CacheIndexSpecs.swift
//  MapCache_Tests
//

import Foundation
import Quick
import Nimble
@testable import MapCache

class CacheIndexSpecs: QuickSpec {

    override func spec() {
        describe("CacheIndex") {
            var index: CacheIndex!

            beforeEach {
                index = CacheIndex()
            }

            it("starts empty") {
                expect(index.totalSize).to(equal(0))
                expect(index.count).to(equal(0))
                expect(index.isEmpty) == true
                expect(index.oldest).to(beNil())
                expect(index.popOldest()).to(beNil())
            }

            it("can add an entry and keeps track of totalSize") {
                index.add(filename: "abc", size: 4096)
                expect(index.count).to(equal(1))
                expect(index.isEmpty) == false
                expect(index.totalSize).to(equal(4096))
                expect(index.oldest?.filename).to(equal("abc"))
                expect(index.oldest?.size).to(equal(4096))
            }

            it("can add an entry with a custom modification date") {
                let past = Date(timeIntervalSince1970: 0)
                index.add(filename: "old", size: 4096, modificationDate: past)
                expect(index.oldest?.modificationDate).to(equal(past))
            }

            it("replaces existing entry on add with same filename") {
                index.add(filename: "x", size: 4096)
                index.add(filename: "x", size: 8192)
                expect(index.count).to(equal(1))
                expect(index.totalSize).to(equal(8192))
            }

            it("maintains entries sorted by modificationDate") {
                let early = Date(timeIntervalSince1970: 100)
                let late = Date(timeIntervalSince1970: 200)
                index.add(filename: "b", size: 4096, modificationDate: late)
                index.add(filename: "a", size: 4096, modificationDate: early)
                expect(index.oldest?.filename).to(equal("a"))
                expect(index.popOldest()?.filename).to(equal("a"))
                expect(index.oldest?.filename).to(equal("b"))
            }

            it("touch updates modificationDate and re-sorts entries") {
                index.add(filename: "x", size: 4096, modificationDate: Date(timeIntervalSince1970: 100))
                index.add(filename: "y", size: 4096, modificationDate: Date(timeIntervalSince1970: 200))
                expect(index.oldest?.filename).to(equal("x"))

                index.touch(filename: "x", modificationDate: Date(timeIntervalSince1970: 300))
                expect(index.oldest?.filename).to(equal("y"))
            }

            it("does nothing when touching a non-existent filename") {
                index.touch(filename: "nonexistent")
                expect(index.count).to(equal(0))
                expect(index.totalSize).to(equal(0))
            }

            it("can remove an entry and keeps track of totalSize") {
                index.add(filename: "a", size: 4096)
                index.add(filename: "b", size: 8192)
                expect(index.totalSize).to(equal(12288))

                index.remove(filename: "a")
                expect(index.count).to(equal(1))
                expect(index.totalSize).to(equal(8192))
                expect(index.oldest?.filename).to(equal("b"))
            }

            it("does nothing when removing a non-existent filename") {
                index.add(filename: "a", size: 4096)
                index.remove(filename: "nonexistent")
                expect(index.count).to(equal(1))
                expect(index.totalSize).to(equal(4096))
            }

            it("popOldest removes and returns the oldest entry") {
                index.add(filename: "old", size: 4096, modificationDate: Date(timeIntervalSince1970: 100))
                index.add(filename: "new", size: 8192, modificationDate: Date(timeIntervalSince1970: 200))

                let entry = index.popOldest()
                expect(entry?.filename).to(equal("old"))
                expect(entry?.size).to(equal(4096))
                expect(index.count).to(equal(1))
                expect(index.totalSize).to(equal(8192))
                expect(index.oldest?.filename).to(equal("new"))
            }

            it("popOldest returns nil when index is empty") {
                expect(index.popOldest()).to(beNil())
            }

            it("removeAll clears all entries and resets totalSize") {
                index.add(filename: "a", size: 4096)
                index.add(filename: "b", size: 8192)
                index.removeAll()
                expect(index.count).to(equal(0))
                expect(index.isEmpty) == true
                expect(index.totalSize).to(equal(0))
                expect(index.oldest).to(beNil())
            }
        }
    }
}
