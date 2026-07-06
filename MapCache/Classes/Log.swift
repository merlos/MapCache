//
//  Log.swift
//  MapCache
//
//  Created by merlos on 02/06/2019.
//


import Foundation
import os

///
/// Thin wrapper around os.Logger that automatically captures file and line numbers.
///
struct Log {
    let logger: Logger

    init(subsystem: String, category: String) {
        logger = Logger(subsystem: subsystem, category: category)
    }

    func trace(_ message: String, file: String = #file, line: Int = #line) {
        logger.log(level: .debug, "\((file as NSString).lastPathComponent):\(line) \(message)")
    }

    func debug(_ message: String, file: String = #file, line: Int = #line) {
        logger.log(level: .debug, "\((file as NSString).lastPathComponent):\(line) \(message)")
    }

    func info(_ message: String, file: String = #file, line: Int = #line) {
        logger.log(level: .info, "\((file as NSString).lastPathComponent):\(line) \(message)")
    }

    func notice(_ message: String, file: String = #file, line: Int = #line) {
        logger.log(level: .default, "\((file as NSString).lastPathComponent):\(line) \(message)")
    }

    func error(_ message: String, file: String = #file, line: Int = #line) {
        logger.log(level: .error, "\((file as NSString).lastPathComponent):\(line) \(message)")
    }

    func fault(_ message: String, file: String = #file, line: Int = #line) {
        logger.log(level: .fault, "\((file as NSString).lastPathComponent):\(line) \(message)")
    }
}

extension Log {
    static let cache = Log(subsystem: "org.merlos.mapcache", category: "cache")
    static let diskcache = Log(subsystem: "org.merlos.mapcache", category: "diskcache")
    static let downloader = Log(subsystem: "org.merlos.mapcache", category: "downloader")
}
