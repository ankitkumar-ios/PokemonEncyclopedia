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
		let exp = expectation(description: "Wait for completion")
		
		var receivedError: Error?
		sut.load { error in
			receivedError = error
			exp.fulfill()
		}
		store.completeRetrieval(with: retrievalError)
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, retrievalError)
	}
	
	
	//MARK: Helper
	
	private func makeSUT(currentDate: @escaping ()->Date = Date.init, file:StaticString = #file, line:UInt = #line)->(sut:LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func anyNSError() -> NSError{
		return  NSError(domain: "any error", code: 0, userInfo: nil)
	}
}
