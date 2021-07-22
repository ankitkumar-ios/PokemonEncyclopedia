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
	
	public init(bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "PokemonEncyclopedia", in: bundle)
		context = container.newBackgroundContext()
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		
		completion(.empty)
	}
		
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
}

private extension NSPersistentContainer {
	enum LoadingError: Swift.Error {
		case modelNotFound
		case failedToLoadPersistenceStore(Swift.Error)
	}
	
	static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
			throw LoadingError.modelNotFound
		}
		
		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		var loadError: Swift.Error?
		container.loadPersistentStores { loadError = $1 }
		try loadError.map { throw LoadingError.failedToLoadPersistenceStore($0) }
		
		return container
	}
}


private extension NSManagedObjectModel {
	static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
		return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0) }
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
