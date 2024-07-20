// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

extension NSFileCoordinator {
    // func coordinate(writingItemAt url: URL, options: NSFileCoordinator.WritingOptions = [], error outError: NSErrorPointer, byAccessor writer: (URL) -> Void) {
    func coordinate(writing data: Data, at url: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            
            func handleWriting(newURL: URL) {
                do {
                    try data.write(to: newURL, options: .atomic)
                    continuation.resume()
                    return
                } catch {
                    continuation.resume(throwing: error)
                    return
                }
            }
            
            var nsError: NSError?
            
            self.coordinate(writingItemAt: url, options: .forReplacing, error: &nsError, byAccessor: handleWriting)
            if let nsError = nsError {
                continuation.resume(throwing: nsError)
                return
            }
        }
    }
    
    /*
    
    
    
    // func coordinate(writingItemAt url: URL, options: NSFileCoordinator.WritingOptions = [], error outError: NSErrorPointer, byAccessor writer: (URL) -> Void)
    
    func coordinate(deletingItemAt url: URL) async throws {
        // fileExists is light so use it to avoid coordinate if the file doesn’t exist.
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            var nsError: NSError?
            self.coordinate(
                writingItemAt: url, options: .forDeleting, error: &nsError, byAccessor: { (newURL: URL) -> Void in
                    do {
                        try FileManager.default.removeItem(atPath: newURL.path)
                        continuation.resume()
                        return
                    } catch {
                        continuation.resume(throwing: error)
                        return
                    }
                }
            )
            if let nsError = nsError {
                continuation.resume(throwing: nsError)
                return
            }
        }
    }
    
    // func coordinate(readingItemAt url: URL, options: NSFileCoordinator.ReadingOptions = [], error outError: NSErrorPointer, byAccessor reader: (URL) -> Void)
    
    func coordinate(readingDataAt url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            var nsError: NSError?
            self.coordinate(
                readingItemAt: url, options: .withoutChanges, error: &nsError,
                byAccessor: { (newURL: URL) -> Void in
                    do {
                        let data = try Data(contentsOf: newURL)
                        continuation.resume(returning: data)
                        return
                    } catch {
                        
                        continuation.resume(throwing: error)
                        return
                    }
                }
            )
            if let nsError = nsError {
                
                continuation.resume(throwing: nsError)
                return
            }
        }
    }
    */
    
}

