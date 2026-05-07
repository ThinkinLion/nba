//
//  NBAFirestoreDayCache.swift
//  nba
//

import Foundation

/// File-backed JSON cache under Caches with a **24h** freshness window (NBA daily-ish updates).
enum NBAFirestoreDayCache {
    static let ttl: TimeInterval = 24 * 60 * 60
    
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    
    private static var directoryURL: URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("NBAFirestoreDayCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    private static func fileURL(key: String) -> URL {
        directoryURL.appendingPathComponent("\(key).json")
    }
    
    static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        let url = fileURL(key: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let mod = attrs[.modificationDate] as? Date else { return nil }
        guard Date().timeIntervalSince(mod) < ttl else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
    
    static func save<T: Encodable>(_ value: T, key: String) {
        let url = fileURL(key: key)
        guard let data = try? encoder.encode(value) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}
