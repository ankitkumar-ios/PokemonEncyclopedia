//
//  LocalFeedLoader.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 07/07/21.
//

import Foundation

public class LocalFeedLoader {
	private let store:FeedStore
	private let currentDate: ()-> Date
	
	public typealias SaveResult = Error?
	
	public init(store: FeedStore, currentDate: @escaping ()->Date){
		self.store = store
		self.currentDate = currentDate
	}
	
	public func save(_ feed:[FeedImage], completion: @escaping (SaveResult)->Void ){
		store.deleteCachedFeed { [weak self] error in
			guard let self = self else { return }
			if let cacheDeletionError = error {
				completion(cacheDeletionError)
				return
			}
			self.cache(feed, with: completion)
		}
	}
	
	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult)->Void ) {
		store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
			guard self != nil else {return}
			
			completion(error)
		}
	}
	
	public func load(){
		store.retrieve()
	}
}

private extension Array where Element == FeedImage {
	func toLocal() -> [LocalFeedImage] {
		return map { LocalFeedImage(id: $0.id, name: $0.name, url: $0.url) }
	}
}

