//
//  FeedCachePolicy.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/07/21.
//

import Foundation


internal final class FeedCachePolicy{
	private init() {}
	private static let calendar = Calendar(identifier: .gregorian)

	private static var maxcacheAgeInDays: Int {
		return 7
	}
	
	internal static func validate(_ timestamp: Date, against date: Date) -> Bool{
		guard let maxCacheAge = calendar.date(byAdding: .day, value: maxcacheAgeInDays, to: timestamp) else {
			return false
		}
		
		return date < maxCacheAge
	}
	
}
