//
//  ManagedFeedImage.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 25/07/21.
//

import CoreData

@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID?
	@NSManaged var name: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache
	
	static func image(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		return NSOrderedSet(array: localFeed.map { local in
			let managed = ManagedFeedImage(context: context)
			managed.id = local.id
			managed.name = local.name
			managed.url = local.url
			return managed
		})
	}
	
	var local: LocalFeedImage {
		return LocalFeedImage(id: id, name: name, url: url)
	}
	
}
