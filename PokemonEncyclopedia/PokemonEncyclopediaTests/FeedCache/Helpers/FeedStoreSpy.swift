//
//  FeedStoreSpy.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 10/07/21.
//

import Foundation
import PokemonEncyclopedia


class FeedStoreSpy: FeedStore {
	typealias DeletionCompletion = (Error?)->Void
	typealias InsertionCompletion = (Error?)->Void
	
	enum ReceivedMessages: Equatable {
		case deleteCachedFeed
		case insert([LocalFeedImage], Date)
		case retrive
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
	
	func retrive() {
		receivedMessage.append(.retrive)
	}
}
