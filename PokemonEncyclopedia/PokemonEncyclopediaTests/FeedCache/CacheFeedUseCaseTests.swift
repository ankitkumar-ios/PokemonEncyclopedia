//
//  CacheFeedUseCaseTests.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 03/07/21.
//

import XCTest
import PokemonEncyclopedia

class LocalFeedLoader {
	private let store:FeedStore
	private let currentDate: ()-> Date
	
	init(store: FeedStore, currentDate: @escaping ()->Date){
		self.store = store
		self.currentDate = currentDate
	}
	
	func save(_ items:[FeedItem], completion: @escaping (Error?)->Void ){
		store.deleteCachedFeed { [weak self] error in
			guard let self = self else { return }
			if let cacheDeletionError = error {
				completion(cacheDeletionError)
				return
			}
			self.cache(items, with: completion)
		}
	}
	
	private func cache(_ items: [FeedItem], with completion: @escaping (Error?)->Void ) {
		store.insert(items, timestamp: currentDate()) { [weak self] error in
			guard self != nil else {return}
			
			completion(error)
		}
	}
}

protocol FeedStore {
	typealias DeletionCompletion = (Error?)->Void
	typealias InsertionCompletion = (Error?)->Void

	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}


class CacheFeedUseCaseTests: XCTestCase {
	
	func test_init_doesNotDeleteCacheUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessage, [])
	}
	
	func test_save_requestsCacheDelete(){
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		sut.save(items) { _ in }
		
		XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed])
	}
	
	func test_save_doesnotRequestCacheInsertionOnDeletionError(){
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		let deletionError = anyNSError()
		
		sut.save(items) { _ in }
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed])
	}
	
	func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let items = [uniqueItem(), uniqueItem()]
		
		sut.save(items) { _ in }
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed, .insert(items, timestamp)])
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
		var receivedResult = [Error?]()
		sut?.save([uniqueItem()]) { receivedResult.append($0) }
		
		sut = nil
		store.completeDeletion(with: anyNSError())
		
		XCTAssertTrue(receivedResult.isEmpty)
	}
	

	func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
		let store = FeedStoreSpy()
		var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		var receivedResult = [Error?]()
		sut?.save([uniqueItem()]) { receivedResult.append($0) }
		
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
		sut.save([uniqueItem()]) { error in
			receivedError = error
			exp.fulfill()
		}

		action()
		wait(for: [exp], timeout: 1.0)
		
		
		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}
	
	private class FeedStoreSpy: FeedStore {
		typealias DeletionCompletion = (Error?)->Void
		typealias InsertionCompletion = (Error?)->Void
		
		enum ReceivedMessages: Equatable {
			case deleteCachedFeed
			case insert([FeedItem], Date)
		}
		
		private(set) var receivedMessage = [ReceivedMessages]()
		
		private var deletionCompletions = [DeletionCompletion]()
		private var insertionCompletions = [InsertionCompletion]()
		
		func deleteCachedFeed(completion: @escaping DeletionCompletion){
			deletionCompletions.append(completion)
			receivedMessage.append(.deleteCachedFeed)
		}
		
		func completeDeletion(with error: Error, at index: Int = 0) {
			deletionCompletions[index](error)
		}
		
		func completeDeletionSuccessfully(at index:Int = 0){
			deletionCompletions[index](nil)
		}
		
		func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
			insertionCompletions.append(completion)
			receivedMessage.append(.insert(items, timestamp))
		}
		
		func completeInsertion(with error: Error, at index:Int = 0) {
			insertionCompletions[index](error)
		}
		
		func completeInsertionSuccessfully(at index:Int = 0) {
			insertionCompletions[index](nil)
		}
		
	}

	
	private func uniqueItem() -> FeedItem {
		return FeedItem.init(id: UUID(), name: "ane", imageURL: anyURL())
	}
	
	private func anyURL() -> URL{
		return URL.init(string: "http://any-url.com")!
	}

	private func anyNSError() -> NSError{
		return  NSError(domain: "any error", code: 0, userInfo: nil)
	}
}
