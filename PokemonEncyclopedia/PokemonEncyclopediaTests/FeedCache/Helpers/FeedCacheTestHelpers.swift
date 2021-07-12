//
//  FeedCacheTestHelpers.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 11/07/21.
//

import Foundation
import PokemonEncyclopedia

func uniqueImage() -> FeedImage {
	return FeedImage.init(id: UUID(), name: "ane", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
	let models = [uniqueImage(), uniqueImage()]
	let local = models.map {LocalFeedImage(id: $0.id, name: $0.name, url: $0.url)}
	return (models, local)
}

extension Date {
	func minusFeedCacheMaxAge() -> Date {
		return adding(days: -feedCacheMaxAgeInDays)
	}
	
	private var feedCacheMaxAgeInDays: Int {
		return 7
	}
	
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
