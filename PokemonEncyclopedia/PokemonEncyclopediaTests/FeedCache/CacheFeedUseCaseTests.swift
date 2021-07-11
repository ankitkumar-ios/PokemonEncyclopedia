//
//  CacheFeedUseCaseTests.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 03/07/21.
//

import XCTest
import PokemonEncyclopedia


class CacheFeedUseCaseTests: XCTestCase {
	
	func test_init_doesNotDeleteCacheUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessage, [])
	}
	
	func test_save_requestsCacheDelete(){
		let (sut, store) = makeSUT()
		sut.save(uniqueImageFeed().models) { _ in }
		
		XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed])
	}
	
	func test_save_doesnotRequestCacheInsertionOnDeletionError(){
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		
		sut.save(uniqueImageFeed().models) { _ in }
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed])
	}
	
	func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let feed = uniqueImageFeed()
		
		sut.save(feed.models) { _ in }
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed, .insert(feed.local, timestamp)])
	}
	
	
	func test_save_failOnDeletionError(){
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		
		expect(sut, toCompleteWithError: deletionError) {
			store.completeDeletion(with: deletionError)
		}
	}
	
	
	func test_save_failOnInsertionError(){
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()
		expect(sut, toCompleteWithError: insertionError) {
			store.completeDeletionSuccessfully()
			store.completeInsertion(with: insertionError)
		}
	}
	
	
	
	func test_save_succeedOnSuccessfulCacheInsertion(){
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWithError: nil) {
			store.completeDeletionSuccessfully()
			store.completeInsertionSuccessfully()
		}
	}
	

	func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated(){
		let store = FeedStoreSpy()
		var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		var receivedResult = [LocalFeedLoader.SaveResult]()
		sut?.save(uniqueImageFeed().models) { receivedResult.append($0) }
		
		sut = nil
		store.completeDeletion(with: anyNSError())
		
		XCTAssertTrue(receivedResult.isEmpty)
	}
	

	func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
		let store = FeedStoreSpy()
		var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		var receivedResult = [LocalFeedLoader.SaveResult]()
		sut?.save(uniqueImageFeed().models) { receivedResult.append($0) }
		
		store.completeDeletionSuccessfully()
		sut = nil
		store.completeInsertion(with: anyNSError())
		
		XCTAssertTrue(receivedResult.isEmpty)
	}
	
	
	
	
	//MARK: Helper
	
	private func makeSUT(currentDate: @escaping ()->Date = Date.init, file:StaticString = #file, line:UInt = #line)->(sut:LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: ()-> Void, file:StaticString = #file, line:UInt = #line) {
		
		let exp = expectation(description: "wait for save")
		
		var receivedError: Error?
		sut.save(uniqueImageFeed().models) { error in
			receivedError = error
			exp.fulfill()
		}

		action()
		wait(for: [exp], timeout: 1.0)
		
		
		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}

}
