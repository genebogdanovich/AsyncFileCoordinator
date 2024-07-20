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
    
    func testWrite() async throws {
        let data = Data("testData".utf8)
        let fileName = "hello"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appendingPathComponent(fileName)
        
        try await NSFileCoordinator().coordinate(writing: data, at: url)
    }
    
    func testWriteError() async throws {
        let data = Data("testData".utf8)
        let fileName = "hello"
        let urlWeDoNotHavePermissionToWriteTo = URL(fileURLWithPath: "/dev/null")
        
        let url = urlWeDoNotHavePermissionToWriteTo.appendingPathComponent(fileName)
        
        
        var error: Error?
        
        do {
            try await NSFileCoordinator().coordinate(writing: data, at: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
    
    func testWriteSimulatedError() async throws {
        let data = Data("testData".utf8)
        let fileName = "hello"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appendingPathComponent(fileName)
        
        var error: Error?
        
        do {
            try await NSFileCoordinatorStub().coordinate(writing: data, at: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
    
    
    func testRead() async throws {
        
        let fileName = "hello"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appendingPathComponent(fileName)
        
        let data = try await NSFileCoordinator().coordinate(readingDataAt: url)
        
        print(data)
    }
    
    
    func testReadError() async throws {
        
        let fileName = "helloo"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appendingPathComponent(fileName)
        
        var error: Error?
        
        do {
            let data = try await NSFileCoordinator().coordinate(readingDataAt: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
    
    
    func testReadSimulatedError() async throws {
        let fileName = "hello"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appendingPathComponent(fileName)
        
        var error: Error?
        
        do {
            let data = try await NSFileCoordinatorStub().coordinate(readingDataAt: url)
        } catch let err {
            error = err
        }
        
        XCTAssertNotNil(error)
    }
    
    
//    func testDelete() async throws {
//        let fileName = "file"
//        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let url = documentDirectory.appendingPathComponent(fileName)
//        
//        try await NSFileCoordinator().coordinate(deletingItemAt: url)
//        
//    }
    
    
}
