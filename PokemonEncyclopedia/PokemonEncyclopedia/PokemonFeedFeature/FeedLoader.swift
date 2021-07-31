//
//  FeedLoader.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/06/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
	func load(completion: @escaping(LoadFeedResult)->Void)
}
