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
	
	func test_load_requestsCacheRetrieval() {
		let (sut, store) = makeSUT()
		
		sut.load {_ in}
		
		XCTAssertEqual(store.receivedMessage, [.retrieval])
	}
	
	func test_load_failsOnRetrievalError(){
		let (sut, store) = makeSUT()
		let retrievalError = anyNSError()
		
		expect(sut, toCompleteWith: .failure(retrievalError), when: {
			store.completeRetrieval(with: retrievalError)
		})
	}
	
	func test_load_deliversNoImagesOnEmptyCache(){
		let (sut, store) = makeSUT()

		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrievalWithEmptyCache()
		})
	}
	
	
	func test_load_deliversCacheImagesOnLessThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThanSevenDaysLoad = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		
		expect(sut, toCompleteWith: .success(feed.models), when: {
			store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysLoad)
		})
	}
	

	func test_load_deliversNoImagesOnSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDaysLoad = fixedCurrentDate.adding(days: -7)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		
		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrieval(with: feed.local, timestamp: sevenDaysLoad)
		})
	}
	
	func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let moreThanSevenDaysLoad = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		
		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysLoad)
		})
	}
	
	
	func test_load_deletesCacheOnRetrievalError(){
		let (sut, store) = makeSUT()
		sut.load { _ in }
		
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessage, [.retrieval, .deleteCachedFeed])
	}
	
	
	//MARK: Helper
	
	private func makeSUT(currentDate: @escaping ()->Date = Date.init, file:StaticString = #file, line:UInt = #line)->(sut:LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line:UInt = #line) {
		let exp = expectation(description: "Wait for completion")

		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
				case let (.success(receivedImages), .success(expectedImages)):
					XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
				case let (.failure(receivedError), .failure(expectedError)):
					XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
				default:
					XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		action()
		wait(for: [exp], timeout: 1.0)
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
