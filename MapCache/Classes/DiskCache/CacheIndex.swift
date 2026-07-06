//
//  CacheIndex.swift
//  MapCache
//

import Foundation

/// In-memory sorted index of cache entries.
///
/// Maintains entries sorted by modification date ascending (oldest first).
/// Provides O(log n) insertion via sort-after-append, O(1) lookup by filename,
/// and O(n) removal with index shift. All mutations update `totalSize` atomically.
///
/// This class is intentionally standalone so multiple `DiskCache` instances or
/// other consumers can share the same indexing logic without coupling to file I/O.
///
/// # Usage
///
/// ```swift
/// let index = CacheIndex()
///
/// // Build from filesystem
/// index.build(from: cacheURL)
///
/// // Track a new file
/// index.add(filename: "abc123", size: 4096)
///
/// // Mark a file as recently accessed (moves it to the end of the sorted order)
/// index.touch(filename: "abc123")
///
/// // Evict the oldest file
/// if let entry = index.popOldest() {
///     try? FileManager.default.removeItem(at: cacheURL.appendingPathComponent(entry.filename))
/// }
///
/// // Remove a specific file
/// index.remove(filename: "abc123")
/// ```
open class CacheIndex {

    /// A single entry in the cache index.
    public struct Entry: Equatable {
        /// MD5 filename (file's `lastPathComponent` in the cache directory).
        public let filename: String
        /// Allocated disk size in bytes.
        public var size: UInt64
        /// Last modification date of the file.
        public var modificationDate: Date
    }

    /// Total allocated disk size of all tracked entries, in bytes.
    open private(set) var totalSize: UInt64 = 0

    /// Number of entries in the index.
    open var count: Int { entries.count }

    /// Whether the index contains no entries.
    open var isEmpty: Bool { entries.isEmpty }

    /// The oldest entry (smallest `modificationDate`), or `nil` if the index is empty.
    open var oldest: Entry? { entries.first }

    /// All entries sorted by modification date ascending.
    private var entries: [Entry] = []

    /// Mapping from filename to index in `entries`.
    private var entryMap: [String: Int] = [:]

    /// Serializes all mutations so `touch` from any thread is safe with respect
    /// to `controlCapacity()` running on `cacheQueue`.
    private let lock = NSRecursiveLock()

    public init() {}

    /// Builds the index by enumerating the filesystem directory.
    ///
    /// Discards any existing index state and replaces it with the contents of
    /// the directory. Each file's allocated size and modification date are read
    /// via the resource keys `isRegularFileKey`, `fileAllocatedSizeKey`, and
    /// `contentModificationDateKey`.
    ///
    /// - Parameter directoryURL: The cache directory URL to enumerate.
    /// - Returns: The total allocated size of all files found.
    @discardableResult
    open func build(from directoryURL: URL) -> UInt64 {
        lock.lock()
        defer { lock.unlock() }
        entries = []
        entryMap = [:]
        totalSize = 0

        let keys: Set<URLResourceKey> = [.isRegularFileKey, .fileAllocatedSizeKey, .contentModificationDateKey]
        guard let enumerator = FileManager.default.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: Array(keys),
            options: .skipsSubdirectoryDescendants) else { return 0 }

        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: keys),
                  values.isRegularFile == true,
                  let fileSize = values.fileAllocatedSize,
                  let modDate = values.contentModificationDate else { continue }

            let entry = Entry(filename: url.lastPathComponent,
                              size: UInt64(fileSize),
                              modificationDate: modDate)
            entryMap[entry.filename] = entries.count
            entries.append(entry)
            totalSize += UInt64(fileSize)
        }

        entries.sort { $0.modificationDate < $1.modificationDate }
        rebuildEntryMap()
        return totalSize
    }

    /// Inserts or replaces an entry in the index.
    ///
    /// If an entry with the same `filename` already exists, it is removed first.
    /// The entry's modification date defaults to the current date when `nil`.
    ///
    /// - Parameters:
    ///   - filename: MD5 filename of the cached file.
    ///   - size: Allocated disk size in bytes.
    ///   - modificationDate: File modification date. Pass `nil` to use the current date.
    open func add(filename: String, size: UInt64, modificationDate: Date? = nil) {
        lock.lock()
        defer { lock.unlock() }
        let date = modificationDate ?? Date()
        remove(filename: filename)

        let entry = Entry(filename: filename, size: size, modificationDate: date)
        entries.append(entry)
        totalSize += size

        entries.sort { $0.modificationDate < $1.modificationDate }
        rebuildEntryMap()
    }

    /// Updates the modification date of an existing entry.
    ///
    /// Does nothing if no entry with the given `filename` exists.
    /// The modification date defaults to the current date when `nil`.
    ///
    /// - Parameters:
    ///   - filename: MD5 filename of the cached file.
    ///   - modificationDate: New modification date. Pass `nil` to use the current date.
    open func touch(filename: String, modificationDate: Date? = nil) {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = entryMap[filename] else { return }
        let date = modificationDate ?? Date()
        entries[idx].modificationDate = date

        entries.sort { $0.modificationDate < $1.modificationDate }
        rebuildEntryMap()
    }

    /// Removes an entry from the index by filename.
    ///
    /// Does nothing and does not produce an error if the filename is not in the index.
    ///
    /// - Parameter filename: MD5 filename of the cached file to remove.
    open func remove(filename: String) {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = entryMap[filename] else { return }
        totalSize -= entries[idx].size
        entries.remove(at: idx)
        for i in idx..<entries.count {
            entryMap[entries[i].filename] = i
        }
        entryMap.removeValue(forKey: filename)
    }

    /// Removes all entries from the index and resets `totalSize` to zero.
    open func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        entries = []
        entryMap = [:]
        totalSize = 0
    }

    /// Removes and returns the oldest entry.
    ///
    /// - Returns: The entry with the smallest `modificationDate`, or `nil` if the index is empty.
    open func popOldest() -> Entry? {
        lock.lock()
        defer { lock.unlock() }
        guard let oldest = oldest else { return nil }
        remove(filename: oldest.filename)
        return oldest
    }

    /// Rebuilds the filename→index mapping from the sorted entries array.
    private func rebuildEntryMap() {
        entryMap = [:]
        for (i, entry) in entries.enumerated() {
            entryMap[entry.filename] = i
        }
    }
}
