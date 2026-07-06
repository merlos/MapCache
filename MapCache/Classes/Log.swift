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
/// Usage:
/// ```
///   Log.cache.debug("my debug message")
///   // prints: MapCache.swift[42]::myMethod -- my debug message
///
///   Log.cache.error("tile not found with error \(error)")
///   // prints: MapCache.swift[99]::fetchTile -- tile not found with error ...
///
///   Log.diskcache.info("cache size calculated")
///   // prints: DiskCache.swift[55]::calculateDiskSize -- cache size calculated
///
///   Log.downloader.trace("network request started")
///   // prints: RegionDownloader.swift[77]::start -- network request started
/// ```
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

    /// Log at `.debug` level. Extremely verbose, not persisted, development only.
    func trace(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .debug, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    /// Log at `.debug` level. Not persisted, useful during development.
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .debug, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    /// Log at `.info` level. Persisted in the log archive, useful for important state changes.
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .info, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    /// Log at `.default` level. Noteworthy events that are not errors.
    func notice(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .default, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    /// Log at `.error` level. Recoverable errors that should be investigated.
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .error, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }

    /// Log at `.fault` level. Critical failures that may impact app stability.
    func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(level: .fault, "\((file as NSString).lastPathComponent)[\(line)]::\(Self.baseName(function)) -- \(message)")
    }
}

///
/// Pre-configured loggers for each MapCache subsystem category.
///
extension Log {

    /// Cache operations (tile fetching, URL building, ETag handling)
    static let cache = Log(subsystem: "org.merlos.mapcache", category: "cache")

    /// Disk storage operations (read/write/eviction)
    static let diskcache = Log(subsystem: "org.merlos.mapcache", category: "diskcache")

    /// Region downloader operations
    static let downloader = Log(subsystem: "org.merlos.mapcache", category: "downloader")
}
