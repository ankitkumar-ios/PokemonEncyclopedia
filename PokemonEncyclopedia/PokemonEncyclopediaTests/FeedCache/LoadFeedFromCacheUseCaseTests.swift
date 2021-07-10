//
//  LoadFeedFromCacheUseCaseTests.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 10/07/21.
//

import XCTest
import PokemonEncyclopedia

class LoadFeedFromcacheUseCaseTest: XCTestCase {
	
	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessage, [])
	}
	
	func test_load_retriveCacheFeed() {
		let (sut, store) = makeSUT()
		
		sut.load()
		
		XCTAssertEqual(store.receivedMessage, [.retrive])
	}
	
	
	//MARK: Helper
	
	private func makeSUT(currentDate: @escaping ()->Date = Date.init, file:StaticString = #file, line:UInt = #line)->(sut:LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

}
