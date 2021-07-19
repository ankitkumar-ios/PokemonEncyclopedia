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
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache(){
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectOnEmptyCache(on: sut)
	}

	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache(){
		let sut = makeSUT()
		
		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache(){
		let sut = makeSUT()
		
		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFailureOnRetrievalError(){
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
		
		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnFailure(){
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)

		try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)

		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache(){
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache(){
		let sut = makeSUT()
		 
		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues(){
		let sut = makeSUT()
		
		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	
	func test_insert_deliversErrorOnInsertionError(){
		let storeURL = URL(string: "invalid://store-url")
		let sut = makeSUT(storeURL: storeURL)
		
		assertThatInsertDeliversErrorOnInsertionError(on: sut)
	}

	
	func test_insert_hasNoSideEffectOnInsertionError(){
		let storeURL = URL(string: "invalid://store-url")
		let sut = makeSUT(storeURL: storeURL)
		
		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache(){
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache(){
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache(){
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache(){
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_delete_deliversErrorOnDeletionError() {
		let noDeletePermissionURL = cachesDirectory()
		let sut = makeSUT(storeURL: noDeletePermissionURL)

		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
	}

	
	func test_delete_hasNoSideEffectOnDeletionError() {
		let noDeletePermissionURL = cachesDirectory()
		let sut = makeSUT(storeURL: noDeletePermissionURL)

		assertThatDeletehasNoSideEffectsOnDeletionError(on: sut)
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
