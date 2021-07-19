//
//  CodableFeedStoreTests.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 14/07/21.
//

import XCTest
import PokemonEncyclopedia

class CodableFeedStoreTests: XCTestCase, FailableFeedStore{

	override func setUp() {
		super.setUp()

		setupEmptyStoreState()
	}
	
	override func tearDown() {
		super.tearDown()
		
		undoStoreSideEffects()
	}

	func test_retrieve_deliversEmptyOnEmptyCache(){
		let sut = makeSUT()
		
		expect(sut, toRetrieve: .empty)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache(){
		let sut = makeSUT()

		expect(sut, toRetrieveTwice: .empty)
	}

	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache(){
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date.init()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache(){
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date.init()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retrieve_deliversFailureOnRetrievalError(){
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)

		try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieve: .failure(anyNSError()))
	}
	
	func test_retrieve_hasNoSideEffectsOnFailure(){
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)

		try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieveTwice: .failure(anyNSError()))
	}
	
	func test_insert_deliversNoErrorOnEmptyCache(){
		let sut = makeSUT()
		
		let insertError = insert((uniqueImageFeed().local, Date()), to: sut)
		
		XCTAssertNil(insertError, "Expect to insert cache successfully")
	}

	func test_insert_deliversNoErrorOnNonEmptyCache(){
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let insertError = insert((uniqueImageFeed().local, Date()), to: sut)
		
		XCTAssertNil(insertError, "Expect to insert cache successfully")
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues(){
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: sut)
		
		expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}
	
	
	func test_insert_deliversErrorOnInsertionError(){
		let storeURL = URL(string: "invalid://store-url")
		let sut = makeSUT(storeURL: storeURL)
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let insertionError = insert((feed, timestamp), to: sut)
		
		XCTAssertNotNil(insertionError, "Expect cache insertion error")
	}

	
	func test_insert_hasNoSideEffectOnInsertionError(){
		let storeURL = URL(string: "invalid://store-url")
		let sut = makeSUT(storeURL: storeURL)
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .empty)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache(){
		let sut = makeSUT()

		let deleteError = deleteCache(from: sut)
		XCTAssertNil(deleteError, "Expected empty cache deletion to succeed")
	}

	func test_delete_hasNoSideEffectsOnEmptyCache(){
		let sut = makeSUT()

		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .empty)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache(){
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let deleteError = deleteCache(from: sut)
		
		XCTAssertNil(deleteError, "Expected empty cache deletion to succeed")
	}
	
	func test_delete_emptiesPreviouslyInsertedCache(){
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)

		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .empty)
	}
	
	func test_delete_deliversErrorOnDeletionError() {
		let noDeletePermissionURL = cachesDirectory()
		let sut = makeSUT(storeURL: noDeletePermissionURL)

		let deletionError = deleteCache(from: sut)

		XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
	}

	
	func test_delete_hasNoSideEffectOnDeletionError() {
		let noDeletePermissionURL = cachesDirectory()
		let sut = makeSUT(storeURL: noDeletePermissionURL)

		deleteCache(from: sut)

		expect(sut, toRetrieve: .empty)
	}

	
	func test_storeSideEffects_runSerially(){
		let sut = makeSUT()
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
	
	
	//MARK:- Helper
	private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func testSpecificStoreURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
	}

	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
	}

	func setupEmptyStoreState(){
		deleteStoreArtifacts()
	}

	func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}
	
	func deleteStoreArtifacts(){
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
}
