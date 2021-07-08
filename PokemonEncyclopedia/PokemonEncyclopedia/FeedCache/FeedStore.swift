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
	func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalFeedItem: Equatable {
	public let id: UUID
	public let name: String?
	public let imageURL: URL
	
	public init(id: UUID, name: String?, imageURL: URL){
		self.id = id
		self.name = name
		self.imageURL = imageURL
	}
}
