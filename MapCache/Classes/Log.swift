//
//  Log.swift
//  MapCache
//
//  Created by merlos on 02/06/2019.
//

import Foundation
import os

///
/// Thin wrapper around os.Logger that automatically captures file, function and line numbers.
///
struct Log {
    let logger: Logger

    init(subsystem: String, category: String) {
        logger = Logger(subsystem: subsystem, category: category)
    }

    private static func baseName(_ function: String) -> String {
        if let parenIndex = function.firstIndex(of: "(") {
            return String(function[..<parenIndex])
        }
        return function
    }

    func trace(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .debug, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .debug, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .info, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    func notice(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .default, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .error, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .fault, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }
}

extension Log {
    static let cache = Log(subsystem: "org.merlos.mapcache", category: "cache")
    static let diskcache = Log(subsystem: "org.merlos.mapcache", category: "diskcache")
    static let downloader = Log(subsystem: "org.merlos.mapcache", category: "downloader")
}
