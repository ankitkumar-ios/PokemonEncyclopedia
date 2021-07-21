//
//  CoreDataFeedStore.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 21/07/21.
//

import Foundation


public class CoreDataFeedStore: FeedStore {
	
	public init() {}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		
		completion(.empty)
	}
		
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
}
