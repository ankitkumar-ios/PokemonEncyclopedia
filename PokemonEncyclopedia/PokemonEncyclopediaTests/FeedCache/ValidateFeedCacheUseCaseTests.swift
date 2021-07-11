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
	
	func test_validateCache_doesNotDeletesLessThanSevenDaysOldCache(){
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThanSevenDaysLoad = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysLoad)
		
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
	
	private func uniqueImage() -> FeedImage {
		return FeedImage.init(id: UUID(), name: "ane", url: anyURL())
	}
	
	private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
		let models = [uniqueImage(), uniqueImage()]
		let local = models.map {LocalFeedImage(id: $0.id, name: $0.name, url: $0.url)}
		return (models, local)
	}
	
	private func anyURL() -> URL{
		return URL.init(string: "http://any-url.com")!
	}
	
	private func anyNSError() -> NSError{
		return  NSError(domain: "any error", code: 0, userInfo: nil)
	}
	
}


private extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
