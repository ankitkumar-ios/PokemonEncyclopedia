//
//  CoreDataFeedStore.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 21/07/21.
//

import CoreData


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



private class ManagedCache: NSManagedObject {
 @NSManaged var timestamp: Date
 @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
 @NSManaged var id: UUID
 @NSManaged var name: String?
 @NSManaged var url: URL
 @NSManaged var cache: ManagedCache
}
