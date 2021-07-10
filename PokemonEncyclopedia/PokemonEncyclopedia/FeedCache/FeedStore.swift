//
//  FeedStore.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 07/07/21.
//

import Foundation

public protocol FeedStore {
	typealias DeletionCompletion = (Error?)->Void
	typealias InsertionCompletion = (Error?)->Void

	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
	func retrieve()
}
