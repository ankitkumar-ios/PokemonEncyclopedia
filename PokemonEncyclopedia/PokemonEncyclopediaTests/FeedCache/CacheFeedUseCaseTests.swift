//
//  CacheFeedUseCaseTests.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 03/07/21.
//

import XCTest
import PokemonEncyclopedia

class LocalFeedLoader {
	let store:FeedStore
	
	init(store: FeedStore){
		self.store = store
	}
	
	func save(_ items:[FeedItem]){
		store.deleteCachedFeed()
	}
}

class FeedStore {
	var deleteCachedFeedCallCount:Int = 0
	
	func deleteCachedFeed(){
		deleteCachedFeedCallCount += 1
	}
}


class CacheFeedUseCaseTests: XCTestCase {
	
	func test_init_doesNotDeleteCacheUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}
	
	func test_save_requestsCacheDelete(){
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		sut.save(items)
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
	}
	
	
	//MARK: Helper
	
	private func makeSUT(file:StaticString = #file, line:UInt = #line)->(sut:LocalFeedLoader, store: FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func uniqueItem() -> FeedItem {
		return FeedItem.init(id: UUID(), name: "ane", imageURL: anyURL())
	}
	
	private func anyURL() -> URL{
		return URL.init(string: "http://any-url.com")!
	}

	
}
