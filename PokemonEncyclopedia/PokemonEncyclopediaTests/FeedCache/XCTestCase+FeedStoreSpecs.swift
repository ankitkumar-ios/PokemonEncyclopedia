//
//  XCTestCase+FeedStoreSpecs.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 19/07/21.
//

import XCTest
import PokemonEncyclopedia

extension FeedStoreSpecs where Self: XCTestCase {
	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for insertion")
		var insertionError: Error?
		
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}
	
	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for delete")
		var deletionError: Error?
		sut.deleteCachedFeed { receivedError in
			deletionError = receivedError
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for completion")
		
		sut.retrieve { receivedResult in
			switch (expectedResult, receivedResult) {
				case (.empty, .empty),
						 (.failure, .failure):
				break
					
				case let (.found(expectedFeed, expectedTimestamp), .found(receivedFeed, receivedTimestamp)):
					XCTAssertEqual(expectedFeed, receivedFeed)
					XCTAssertEqual(expectedTimestamp, receivedTimestamp)

				default:
					XCTFail("Expected to retrieve expected \(expectedResult) , got \(receivedResult) instead")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	
	func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	
}
