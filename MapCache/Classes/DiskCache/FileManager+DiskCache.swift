//
//  FileManager+DiskCache.swift
//  MapCache
//
//  Created by merlos on 02/06/2019.
//

// Original source code from Haneke
//
// https://github.com/Haneke/HanekeSwift/blob/master/Haneke/NSFileManager%2BHaneke.swift
// Created by Hermes Pique on 8/26/14.


import Foundation

///
/// Class for handling the operations with file folders.
///
/// Original source code from [Haneke](https://github.com/Haneke/HanekeSwift/blob/master/Haneke/NSFileManager%2BHaneke.swift)
///
extension FileManager {
    
    /// Calculate the allocated size of a directory and all its contents on the volume.
    ///
    /// As there's no simple way to get this information from the file system the method
    /// has to crawl the entire hierarchy, accumulating the overall sum on the way.
    /// The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - Note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    func allocatedDiskSizeForDirectory(at directoryURL: URL) throws -> UInt64 {
        
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        
        /// Error handler in case there is a problem when getting the information from the disk
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }
        
        let allocatedSizeResourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
        ]
        
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [],
                                         errorHandler: errorHandler)!
        
        // We'll sum up content size here:
        var accumulatedSize: UInt64 = 0
        
        // Perform the traversal.
        for item in enumerator {
            
            // Bail out on errors from the errorHandler.
            if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            accumulatedSize += try contentItemURL.regularFileAllocatedDiskSize()
        }
        
        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }
        
        return accumulatedSize
    }
    
    /// Calculates the actual sum of file sizes
    func fileSizeForDirectory(at directoryURL: URL) throws -> UInt64 {
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        
        /// Handler in case of error when calculating the filesize
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }
        let allocatedSizeResourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileSizeKey
        ]
        
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [],
                                         errorHandler: errorHandler)!
        
        // We'll sum up content size here:
        var accumulatedSize: UInt64 = 0
        // Perform the traversal.
        for item in enumerator {
            // Bail out on errors from the errorHandler.
            if enumeratorError != nil { break }
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            accumulatedSize += try contentItemURL.regularFileSize()
        }
        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }
        return accumulatedSize
    }
}

/// Overload of the the `<` operator
func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == ComparisonResult.orderedAscending
}


