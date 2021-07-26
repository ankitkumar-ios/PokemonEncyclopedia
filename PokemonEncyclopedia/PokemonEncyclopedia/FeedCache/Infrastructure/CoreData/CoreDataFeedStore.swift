//
//  CoreDataFeedStore.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 21/07/21.
//

import CoreData


public class CoreDataFeedStore: FeedStore {
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL, bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "PokemonEncyclopedia", url: storeURL, in: bundle)
		context = container.newBackgroundContext()
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			do {
				if let cache = try ManagedCache.find(in: context) {
					completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
				} else {
					completion(.empty)
				}
				
			}
			catch{
				completion(.failure(error))
			}
		}
		
	}
		
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			do {
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				managedCache.timestamp = timestamp
				managedCache.feed = ManagedFeedImage.image(from: feed, in: context)
				
				try context.save()
				completion(nil)
			}
			catch {
				completion(error)
			}
		}
		
		
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			do {
				try ManagedCache.find(in: context).map(context.delete)
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	private func perform(_ action: @escaping (NSManagedObjectContext)-> Void) {
		let context = self.context
		context.perform { action(context) }
	}
	
}