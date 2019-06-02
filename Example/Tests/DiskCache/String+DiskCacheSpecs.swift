//
//  String+MapCacheSpecs.swift
//  MapCache_Tests
//
//  Created by merlos on 02/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import MapCache


class String_DiskCacheSpecs: QuickSpec {
    override func spec() {
        describe("String") {
            it("can calculate MD5") {
                let hello = "Hello"
                expect(hello.toMD5()) == "8b1a9953c4611296a827abf8c47804d7"
            }
        }
    }
}
