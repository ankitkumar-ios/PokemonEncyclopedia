//
//  FeedLoader.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/06/21.
//

import Foundation

public enum LoadFeedResult {
	case success([FeedItem])
	case failure(Error)
}

public protocol FeedLoader {
	func load(completion: @escaping(LoadFeedResult)->Void)
}
