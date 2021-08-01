//
//  FeedStoreSpy.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 10/07/21.
//

import Foundation
import PokemonEncyclopedia


class FeedStoreSpy: FeedStore {
	enum ReceivedMessages: Equatable {
		case deleteCachedFeed
		case insert([LocalFeedImage], Date)
		case retrieval
	}
	
	private(set) var receivedMessage = [ReceivedMessages]()
	
	private var deletionCompletions = [DeletionCompletion]()
	private var insertionCompletions = [InsertionCompletion]()
	private var retrievalCompletions = [RetrievalCompletion]()
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion){
		deletionCompletions.append(completion)
		receivedMessage.append(.deleteCachedFeed)
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](.failure(error))
	}
	
	func completeDeletionSuccessfully(at index:Int = 0){
		deletionCompletions[index](.success(()))
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		insertionCompletions.append(completion)
		receivedMessage.append(.insert(feed, timestamp))
	}
	
	func completeInsertion(with error: Error, at index:Int = 0) {
		insertionCompletions[index](.failure(error))
	}
	
	func completeInsertionSuccessfully(at index:Int = 0) {
		insertionCompletions[index](.success(()))
	}
	
	func retrieve(completion: @escaping RetrievalCompletion ) {
		retrievalCompletions.append(completion)
		receivedMessage.append(.retrieval)
	}
	
	func completeRetrieval(with error: Error, at index:Int = 0) {
		retrievalCompletions[index](.failure(error))
	}
	
	func completeRetrievalWithEmptyCache(at index:Int = 0) {
		retrievalCompletions[index](.success(nil))
	}
	
	func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index:Int = 0) {
		retrievalCompletions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
	}
	
}
