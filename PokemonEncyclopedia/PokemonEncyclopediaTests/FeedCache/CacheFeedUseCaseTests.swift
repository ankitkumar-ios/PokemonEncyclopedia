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
		let store = FeedStore()
		_ = LocalFeedLoader(store: store)
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}
	
	func test_save_requestsCacheDelete(){
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		
		let items = [uniqueItem(), uniqueItem()]
		sut.save(items)
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
	}
	
	
	//MARK: Helper
	private func uniqueItem() -> FeedItem {
		return FeedItem.init(id: UUID(), name: "ane", imageURL: anyURL())
	}
	
	private func anyURL() -> URL{
		return URL.init(string: "http://any-url.com")!
	}

	
}
