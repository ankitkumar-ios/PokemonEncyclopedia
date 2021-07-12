//
//  ValidateFeedCacheUseCaseTests.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 11/07/21.
//

import XCTest
import PokemonEncyclopedia

class ValidateFeedCacheUseCaseTests: XCTestCase {
	
	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessage, [])
	}
	
	func test_validateCache_deletesCacheOnRetrievalError(){
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessage, [.retrieval, .deleteCachedFeed])
	}
	
	
	func test_validateCache_doesNotDeletesCacheOnEmptyCache(){
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertEqual(store.receivedMessage, [.retrieval])
	}
	
	func test_validateCache_doesNotDeletesNonExpireCache(){
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let nonExpireTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)

		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: nonExpireTimestamp)
		
		XCTAssertEqual(store.receivedMessage, [.retrieval])
	}
	
	
	func test_validateCache_deleteCacheOnCacheExpiration(){
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expirationTimestamp = fixedCurrentDate.adding(days: -7)
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
		
		XCTAssertEqual(store.receivedMessage, [.retrieval, .deleteCachedFeed])
	}
	
	
	func test_validateCache_deleteCacheOnExpiredCache(){
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiredTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
		
		XCTAssertEqual(store.receivedMessage, [.retrieval, .deleteCachedFeed])
	}
	
	
	func test_validateCache_doesnotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated(){
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		sut?.validateCache()
		
		sut = nil
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessage, [.retrieval])
	}
	
	
	//MARK:- Helper
	
	private func makeSUT(currentDate: @escaping ()->Date = Date.init, file:StaticString = #file, line:UInt = #line)->(sut:LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
}
