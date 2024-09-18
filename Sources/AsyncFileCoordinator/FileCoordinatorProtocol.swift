//
//  FileCoordinatorProtocol.swift
//  AsyncFileCoordinator
//
//  Created by Gene Bogdanovich on 18.09.24.
//

import Foundation

protocol FileCoordinatorProtocol {
    func coordinate(writingItemAt url: URL, options: NSFileCoordinator.WritingOptions, error outError: NSErrorPointer, byAccessor writer: (URL) -> Void)
    func coordinate(readingItemAt url: URL, options: NSFileCoordinator.ReadingOptions, error outError: NSErrorPointer, byAccessor reader: (URL) -> Void)
}
