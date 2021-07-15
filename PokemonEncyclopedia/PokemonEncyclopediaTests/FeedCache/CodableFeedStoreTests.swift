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
		
		let decoder = JSONDecoder()
		let cache = try! decoder.decode(Cache.self, from: data)
		completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
		let encoder = JSONEncoder()
		let cache = Cache(feed: feed.map( CodableFeedImage.init ), timestamp: timestamp)
		let encoded = try! encoder.encode(cache)
		try! encoded.write(to: storeURL)
		completion(nil)
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
		let exp = expectation(description: "Wait for completion")
		
		sut.retrieve{ result in
			switch result {
				case .empty:
					break
				default:
					XCTFail("Expected empty result, got \(result) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache(){
		let sut = makeSUT()
		let exp = expectation(description: "Wait for completion")
		
		sut.retrieve{ firstResult in
			sut.retrieve{ secondResult in
				switch (firstResult, secondResult) {
					case (.empty, .empty):
						break
					default:
						XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) & \(secondResult) instead")
				}
				exp.fulfill()
			}
		}
		
		wait(for: [exp], timeout: 1.0)
	}

	
	func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValue(){
		let sut = makeSUT()
		let exp = expectation(description: "Wait for completion")
		let feed = uniqueImageFeed().local
		let timestamp = Date.init()
		
		
		sut.insert(feed, timestamp: timestamp) { insertionError in
			XCTAssertNil(insertionError, "Expected feed to be inserted Successfully")
			
			sut.retrieve { receivedResult in
				switch receivedResult {
					case let .found(feed: retrieveFeed, timestamp: retrieveTimestamp):
						XCTAssertEqual(retrieveFeed, feed)
						XCTAssertEqual(retrieveTimestamp, timestamp)
						
					default:
						XCTFail("Expected found result with feed \(feed) & timestamp \(timestamp), got \(receivedResult) instead")
				}
				
				exp.fulfill()
			}
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache(){
		let sut = makeSUT()
		let exp = expectation(description: "Wait for completion")
		let feed = uniqueImageFeed().local
		let timestamp = Date.init()
		
		
		sut.insert(feed, timestamp: timestamp) { insertionError in
			XCTAssertNil(insertionError, "Expected feed to be inserted Successfully")
			
			sut.retrieve { firstResult in
				sut.retrieve { secondResult in
					switch (firstResult, secondResult) {
						case let (.found(firstFeed, fristTimestamp), .found(secondFeed, secondTimestamp)):
							XCTAssertEqual(firstFeed, feed)
							XCTAssertEqual(fristTimestamp, timestamp)

							XCTAssertEqual(secondFeed, feed)
							XCTAssertEqual(secondTimestamp, timestamp)

						default:
							XCTFail("Expected retrieving twice from non empty cache to deliver the same found result with feed \(feed) & timestamp \(timestamp), got \(firstResult) & \(secondResult) instead")
					}
					
					exp.fulfill()
				}
			}
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	
	
	//MARK:- Helper
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
		let storeURL = testSpecificStoreURL()
		
		let sut = CodableFeedStore(storeURL: storeURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func testSpecificStoreURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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
