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
		expect(sut, toRetrieve: .success(nil), file: file, line:line)
	}
	
	func assertThatRetrieveHasNoSideEffectOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
		expect(sut, toRetrieveTwice: .success(nil), file: file, line:line)
	}
	
	func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date.init()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line:line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date.init()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line:line)
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
		
		expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
	}
	

	func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let deleteError = deleteCache(from: sut)
		
		XCTAssertNil(deleteError, "Expected empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .success(nil), file: file, line: line)
	}
	
	
	func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let deleteError = deleteCache(from: sut)
		
		XCTAssertNil(deleteError, "Expected empty cache deletion to succeed", file: file, line: line)
	}
	
	
	func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)

		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .success(nil), file: file, line: line)
	}

	func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line:UInt = #line){
		var completedOperationInOrder = [XCTestExpectation]()
		
		let op1 = expectation(description: "Wait for Operation 1")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationInOrder.append(op1)
			op1.fulfill()
		}
		
		let op2 = expectation(description: "Wait for Operation 2")
		sut.deleteCachedFeed { _ in
			completedOperationInOrder.append(op2)
			op2.fulfill()
		}
		
		let op3 = expectation(description: "Wait for Operation 3")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationInOrder.append(op3)
			op3.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
		
		XCTAssertEqual(completedOperationInOrder, [op1, op2, op3], "Expected side-effect to run serially but operation finished in wrong order")
		
	}
	
	
	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for insertion")
		var insertionError: Error?
		
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionResult in
			switch receivedInsertionResult {
				case let .failure(error):
					insertionError = error
				case .success:
					break
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}
	
	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for delete")
		var deletionError: Error?
		sut.deleteCachedFeed { receivedResult in
			switch receivedResult {
				case .success:
					break
				case let .failure(error):
					deletionError = error
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file:StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for completion")
		
		sut.retrieve { receivedResult in
			switch (expectedResult, receivedResult) {
				case (.success(nil), .success(nil)),
						 (.failure, .failure):
				break
					
				case let (.success(expectedCachedFeed), .success(receivedCachedFeed)):
					XCTAssertEqual(expectedCachedFeed?.feed, receivedCachedFeed?.feed)
					XCTAssertEqual(expectedCachedFeed?.timestamp, receivedCachedFeed?.timestamp)

				default:
					XCTFail("Expected to retrieve expected \(expectedResult) , got \(receivedResult) instead")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	
	func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file:StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
}
