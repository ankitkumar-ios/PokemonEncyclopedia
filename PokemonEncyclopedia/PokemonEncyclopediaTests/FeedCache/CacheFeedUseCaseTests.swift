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
		store.deleteCachedFeed { [unowned self] error in
			completion(error)
			if error == nil {
				self.store.insert(items, timestamp: currentDate())
			}
		}
	}
}

class FeedStore {
	typealias DeletionCompletion = (Error?)->Void
	
	enum ReceivedMessages: Equatable {
		case deleteCachedFeed
		case insert([FeedItem], Date)
	}
	
	private(set) var receivedMessage = [ReceivedMessages]()
	
	private var deletionCompletions = [DeletionCompletion]()
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
	
	func insert(_ items: [FeedItem], timestamp: Date) {
		receivedMessage.append(.insert(items, timestamp))
	}
	
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
		let items = [uniqueItem(), uniqueItem()]
		let deletionError = anyNSError()
		var receivedError: Error?
		
		let exp = expectation(description: "wait for save")
		
		sut.save(items) { error in
			receivedError = error
			exp.fulfill()
		}
		store.completeDeletion(with: deletionError)
		
		wait(for: [exp], timeout: 1.0)
		
		
		XCTAssertEqual(receivedError as NSError?, deletionError)
	}
	
	
	
	
	//MARK: Helper
	
	private func makeSUT(currentDate: @escaping ()->Date = Date.init, file:StaticString = #file, line:UInt = #line)->(sut:LocalFeedLoader, store: FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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

	private func anyNSError() -> NSError{
		return  NSError(domain: "any error", code: 0, userInfo: nil)
	}
}
