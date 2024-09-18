import XCTest
@testable import AsyncFileCoordinator

final class AsyncFileCoordinatorTests: XCTestCase {
    
    class NSFileCoordinatorStub: NSFileCoordinator {
        
        override func coordinate(writingItemAt url: URL, options: NSFileCoordinator.WritingOptions = [], error outError: NSErrorPointer, byAccessor writer: (URL) -> Void) {
            let error = NSError(domain: NSCocoaErrorDomain, code: NSFileWriteNoPermissionError, userInfo: nil)
            outError?.pointee = error
        }
        
        override func coordinate(readingItemAt url: URL, options: NSFileCoordinator.ReadingOptions = [], error outError: NSErrorPointer, byAccessor reader: (URL) -> Void) {
            let error = NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
            outError?.pointee = error
        }
    }
    
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func testWrite() async throws {
        let data = Data("testData".utf8)
        let fileName = "write"
        
        let url = documentDirectory.appendingPathComponent(fileName)
        
        try await FileCoordinator().coordinate(writing: data, at: url)
    }
    
    func testWriteError() async throws {
        let data = Data("testData".utf8)
        let fileName = "write"
        let urlWeDoNotHavePermissionToWriteTo = URL(fileURLWithPath: "/dev/null")
        
        let url = urlWeDoNotHavePermissionToWriteTo.appendingPathComponent(fileName)
        
        
        var error: Error?
        
        do {
            try await FileCoordinator().coordinate(writing: data, at: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
    
    func testWriteSimulatedError() async throws {
        let data = Data("testData".utf8)
        let fileName = "write"
        
        let url = documentDirectory.appendingPathComponent(fileName)
        
        var error: Error?
        
        do {
            try await FileCoordinator(coordinator: NSFileCoordinatorStub()).coordinate(writing: data, at: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
    
    
    func testRead() async throws {
        
        let fileName = "read"
        
        let url = documentDirectory.appendingPathComponent(fileName)
        let data = Data("testData".utf8)
        
        try await FileCoordinator().coordinate(writing: data, at: url)
        
        let result = try await FileCoordinator().coordinate(readingDataAt: url)
        
        print(result)
    }
    
    
    func testReadError() async throws {
        
        let fileName = "no-such-file"
        
        let url = documentDirectory.appendingPathComponent(fileName)
        
        var error: Error?
        
        do {
            let _ = try await FileCoordinator().coordinate(readingDataAt: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
    
    
    func testReadSimulatedError() async throws {
        let fileName = "read"
        
        let url = documentDirectory.appendingPathComponent(fileName)
        
        var error: Error?
        
        do {
            let _ = try await FileCoordinator(coordinator: NSFileCoordinatorStub()).coordinate(readingDataAt: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
    
    
    func testDelete() async throws {
        let data = Data("testData".utf8)
        let fileName = "delete"
        
        let url = documentDirectory.appendingPathComponent(fileName)
        
        try await FileCoordinator().coordinate(writing: data, at: url)
        
        try await FileCoordinator().coordinate(deletingItemAt: url)
    }
    
    
    
    func testDeleteError() async throws {
        
        let fileName = "no-such-file"
        
        let url = documentDirectory.appendingPathComponent(fileName)
        
        var error: Error?
        
        do {
            try await FileCoordinator().coordinate(deletingItemAt: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
    
    
    func testDeleteSimulatedError() async throws {
        
        let data = Data("testData".utf8)
        let fileName = "testDeleteSimulatedError"
        
        let url = documentDirectory.appendingPathComponent(fileName)
        
        try await FileCoordinator().coordinate(writing: data, at: url)
        
        var error: Error?
        
        do {
            try await FileCoordinator(coordinator: NSFileCoordinatorStub()).coordinate(deletingItemAt: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
}
