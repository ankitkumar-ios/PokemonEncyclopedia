//
//  PokemonEncyclopediaCacheIntegrationTests.swift
//  PokemonEncyclopediaCacheIntegrationTests
//
//  Created by Ankit on 26/07/21.
//

import XCTest
import PokemonEncyclopedia

class PokemonEncyclopediaCacheIntegrationTests: XCTestCase {

	override func setUp() {
		setupEmptyStoreState()
	}
	
	override func tearDown() {
		undoStoreSideEffects()
	}
	
	
	func test_load_deliversNoItemsOnEmptyCache() {
		let sut = makeSUT()
		let exp = expectation(description: "Wait for completion")
		
		sut.load { result in
			switch result {
				case let .success(imageFeed):
					XCTAssertEqual(imageFeed, [], "Expected empty feed")
				case let .failure(error):
					XCTFail("Expected successful feed, got \(error) instead")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	
	//MARK:- Helper
	func makeSUT() -> LocalFeedLoader {
		let storeBundle = Bundle(for: CoreDataFeedStore.self)
		let storeURL = testSpecificURL()
		let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
		
		let sut = LocalFeedLoader(store: store, currentDate: Date.init)
		trackForMemoryLeaks(store)
		trackForMemoryLeaks(sut)
		
		return sut
	}

	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}
	
	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificURL())
	}
	
	
	private func testSpecificURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
	}

	func cacheDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}

}
