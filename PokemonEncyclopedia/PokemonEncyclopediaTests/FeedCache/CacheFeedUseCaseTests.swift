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
		store.deleteCachedFeed { [unowned self] error in
			if error == nil {
				self.store.insert(items)
			}
		}
	}
}

class FeedStore {
	typealias DeletionCompletion = (Error?)->Void
	
	var deleteCachedFeedCallCount:Int = 0
	var insertCallCount = 0
	
	private var deletionCompletions = [DeletionCompletion]()
	func deleteCachedFeed(completion: @escaping DeletionCompletion){
		deleteCachedFeedCallCount += 1
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](error)
	}
	
	func completeDeletionSuccessfully(at index:Int = 0){
		deletionCompletions[index](nil)
	}
	
	func insert(_ items: [FeedItem]) {
		insertCallCount += 1
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
	
	func test_save_doesnotRequestCacheInsertionOnDeletionError(){
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		let deletionError = anyNSError()
		
		sut.save(items)
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.insertCallCount, 0)
	}

	func test_save_requestNewCacheInsertionOnSuccessfulDeletion(){
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		
		sut.save(items)
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.insertCallCount, 1)
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

	private func anyNSError() -> NSError{
		return  NSError(domain: "any error", code: 0, userInfo: nil)
	}
}
