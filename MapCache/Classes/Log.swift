//
//  Log.swift
//  MapCache
//
//  Created by merlos on 02/06/2019.
//
// Based on Haneke' Log File
// https://github.com/Haneke/HanekeSwift/blob/master/Haneke/Log.swift
//


import Foundation

///
/// A struct to log messages on console.
///
/// Format is:
/// ```
///   <tag><Level> <message> [with error <error>]
/// ```
///
struct Log {
    
    /// The tag
    fileprivate static let tag = "[MapCache]"
    
    /// Levels
    fileprivate enum Level : String {
        /// For displaying messages useful during development.
        case Debug = "[DEBUG]"
        /// For displaying bad, very, very bad situations.
        case Error = "[ERROR]"
    }
    
    ///
    /// The actual method that prints.
    ///
    fileprivate static func log(_ level: Level, _ message: @autoclosure () -> String, _ error: Error? = nil) {
        if let error = error {
            print("\(tag)\(level.rawValue) \(message()) with error \(error)")
        } else {
            print("\(tag)\(level.rawValue) \(message())")
        }
    }
    
    ///
    /// For displaying messages. Useful during development of this package.
    ///
    /// Example:
    /// ```
    /// Log.debug("Hello world") // prints: [MapCache][DEBUG] Hello word
    /// ```
    ///
    /// These messages are displayed only if DEBUG is defined
    ///
    static func debug(message: @autoclosure () -> String, error: Error? = nil) {
        #if DEBUG
        log(.Debug, message(), error)
        #endif
    }
    
    ///
    /// These messages are displayed independently of the debug mode.
    /// Used  to provide useful information on exceptional situations to library users.
    ///
    static func error(message: @autoclosure () -> String, error: Error? = nil) {
        log(.Error, message(), error)
    }
    
}
