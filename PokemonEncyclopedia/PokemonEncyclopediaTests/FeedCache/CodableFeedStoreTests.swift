//
//  CodableFeedStoreTests.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 14/07/21.
//

import XCTest
import PokemonEncyclopedia

class CodableFeedStore {
	
	private struct Cache: Codable {
		var feed: [CodableFeedImage]
		var timestamp: Date
		
		var localFeed: [LocalFeedImage] {
			return feed.map { $0.local }
		}
	}
	
	private struct CodableFeedImage: Codable {
		private let id: UUID?
		private let name: String?
		private let url: URL
		
		init(_ image:LocalFeedImage) {
			self.id = image.id
			self.name = image.name
			self.url = image.url
			
		}
		
		var local: LocalFeedImage {
			return LocalFeedImage(id: id, name: name, url: url)
		}
	}
	
	private var storeURL: URL
	init(storeURL: URL) {
		self.storeURL = storeURL
	}
	
	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		guard let data = try? Data(contentsOf: storeURL) else{
			return completion(.empty)
		}
		do {
			let decoder = JSONDecoder()
			let cache = try decoder.decode(Cache.self, from: data)
			completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
		}
		catch{
			completion(.failure(error))
		}
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
		do {
			let encoder = JSONEncoder()
			let cache = Cache(feed: feed.map( CodableFeedImage.init ), timestamp: timestamp)
			let encoded = try encoder.encode(cache)
			try encoded.write(to: storeURL)
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	func deleteCacheFeed(completion: @escaping FeedStore.DeletionCompletion){
		guard FileManager.default.fileExists(atPath: storeURL.path) else {
			return completion(nil)
		}
		
		do {
			try FileManager.default.removeItem(at: storeURL)
			completion(nil)
		}
		catch{
			completion(error)
		}
	}
}

class CodableFeedStoreTests: XCTestCase {

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
	
	func test_insert_overridesPreviouslyInsertedCacheValues(){
		let sut = makeSUT()

		let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		XCTAssertNil(firstInsertionError, "expect to insert cache successfully")
		
		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
		
		XCTAssertNil(latestInsertionError, "expect to insert cache successfully")
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
	
	func test_delete_hasNoSideEffectsOnEmptyCache(){
		let sut = makeSUT()

		let deleteError = deleteCache(from: sut)
		XCTAssertNil(deleteError, "Expected empty cache deletion to succeed")
		
		expect(sut, toRetrieve: .empty)
	}
	

	func test_delete_emptiesPreviouslyInsertedCache(){
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)

		let deleteError = deleteCache(from: sut)
		XCTAssertNil(deleteError, "Expected empty cache deletion to succeed")
		
		expect(sut, toRetrieve: .empty)
	}
	
	func test_delete_deliversErrorOnDeletionError() {
		let noDeletePermissionURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: noDeletePermissionURL)

		let deletionError = deleteCache(from: sut)

		XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
		expect(sut, toRetrieve: .empty)
	}

	
	//MARK:- Helper
	private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	@discardableResult
	private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) -> Error? {
		let exp = expectation(description: "Wait for insertion")
		var insertionError: Error?
		
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}
	
	private func deleteCache(from sut: CodableFeedStore) -> Error? {
		let exp = expectation(description: "Wait for delete")
		var deletionError: Error?
		sut.deleteCacheFeed { receivedError in
			deletionError = receivedError
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line: UInt = #line) {
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
	
	
	private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	
	private func testSpecificStoreURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
	}

//	private func cachesDirectory() -> URL {
//		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
//	}

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
