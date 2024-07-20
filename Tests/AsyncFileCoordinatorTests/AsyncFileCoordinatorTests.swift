import XCTest
@testable import AsyncFileCoordinator

final class AsyncFileCoordinatorTests: XCTestCase {
    
    class NSFileCoordinatorStub: NSFileCoordinator {
        override func coordinate(writingItemAt url: URL, options: NSFileCoordinator.WritingOptions = [], error outError: NSErrorPointer, byAccessor writer: (URL) -> Void) {
            let error = NSError(domain: NSCocoaErrorDomain, code: NSFileWriteOutOfSpaceError, userInfo: nil)
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
    
    
    
   
    
    
//    func testDelete() async throws {
//        let fileName = "file"
//        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let url = documentDirectory.appendingPathComponent(fileName)
//        
//        try await NSFileCoordinator().coordinate(deletingItemAt: url)
//        
//    }
    
    
}
