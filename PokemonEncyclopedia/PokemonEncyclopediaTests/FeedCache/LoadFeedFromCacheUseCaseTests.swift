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
	
	
	
	//MARK: Helper
	
	private func makeSUT(currentDate: @escaping ()->Date = Date.init, file:StaticString = #file, line:UInt = #line)->(sut:LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private class FeedStoreSpy: FeedStore {
		typealias DeletionCompletion = (Error?)->Void
		typealias InsertionCompletion = (Error?)->Void
		
		enum ReceivedMessages: Equatable {
			case deleteCachedFeed
			case insert([LocalFeedImage], Date)
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
		
		func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
			insertionCompletions.append(completion)
			receivedMessage.append(.insert(feed, timestamp))
		}
		
		func completeInsertion(with error: Error, at index:Int = 0) {
			insertionCompletions[index](error)
		}
		
		func completeInsertionSuccessfully(at index:Int = 0) {
			insertionCompletions[index](nil)
		}
		
	}

}
