//
//  XCTestCase+FeedStoreSpecs.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 19/07/21.
//

import XCTest
import PokemonEncyclopedia

extension FeedStoreSpecs where Self: XCTestCase {
	
	func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
		expect(sut, toRetrieve: .empty, file: file, line:line)
	}
	
	func assertThatRetrieveHasNoSideEffectOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
		expect(sut, toRetrieveTwice: .empty, file: file, line:line)
	}
	
	func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date.init()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp), file: file, line:line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date.init()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line:line)
	}

	
	
	
	func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		
		let insertError = insert((uniqueImageFeed().local, Date()), to: sut)
		
		XCTAssertNil(insertError, "Expect to insert cache successfully", file: file, line: line)
	}
	
	func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let insertError = insert((uniqueImageFeed().local, Date()), to: sut)
		
		XCTAssertNil(insertError, "Expect to insert cache successfully", file: file, line: line)
	}
	
	func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: sut)
		
		expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
	}
	

	func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let deleteError = deleteCache(from: sut)
		
		XCTAssertNil(deleteError, "Expected empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .empty, file: file, line: line)
	}
	
	
	func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let deleteError = deleteCache(from: sut)
		
		XCTAssertNil(deleteError, "Expected empty cache deletion to succeed", file: file, line: line)
	}
	
	
	func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)

		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .empty, file: file, line: line)
	}

	
	
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


extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
	
	func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		
		expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		
		expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
	}
	
}



extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
	
	func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let insertionError = insert((feed, timestamp), to: sut)
		
		XCTAssertNotNil(insertionError, "Expect cache insertion error", file: file, line: line)
	}
	
	
	func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .empty, file: file, line: line)
	}
	
	
}

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
	
	func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let deletionError = deleteCache(from: sut)

		XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
	}
	
	
	func assertThatDeletehasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		deleteCache(from: sut)

		expect(sut, toRetrieve: .empty, file: file, line: line)
	}
	
}
