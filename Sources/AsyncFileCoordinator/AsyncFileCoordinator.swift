// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct FileCoordinator<FileCoordinatorType: FileCoordinatorProtocol> {
    
    private let coordinator: FileCoordinatorType
    
    internal init(coordinator: FileCoordinatorType) {
        self.coordinator = coordinator
    }
    
    public init() where FileCoordinatorType == NSFileCoordinator {
        self.coordinator = NSFileCoordinator()
    }
    
    
    // func coordinate(writingItemAt url: URL, options: NSFileCoordinator.WritingOptions = [], error outError: NSErrorPointer, byAccessor writer: (URL) -> Void) {
    public func coordinate(writing data: Data, at url: URL) async throws {
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
            
            coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &nsError, byAccessor: handleWriting)
            if let nsError = nsError {
                continuation.resume(throwing: nsError)
                return
            }
        }
    }
    
    // func coordinate(readingItemAt url: URL, options: NSFileCoordinator.ReadingOptions = [], error outError: NSErrorPointer, byAccessor reader: (URL) -> Void)
    
    public func coordinate(readingDataAt url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            var nsError: NSError?
            coordinator.coordinate(
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
    
    // func coordinate(writingItemAt url: URL, options: NSFileCoordinator.WritingOptions = [], error outError: NSErrorPointer, byAccessor writer: (URL) -> Void)
    
    public func coordinate(deletingItemAt url: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            var nsError: NSError?
            coordinator.coordinate(
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
}
