//
//  FeedItemMapper.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/06/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
	internal let id: UUID
	internal let name: String
	internal let url: URL
}

internal final class FeedItemsMapper{
	
	private struct Root: Decodable {
		let results:[RemoteFeedItem]
	}
	
	private static var OK_200: Int {return 200}
	

	internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem]{
		guard response.statusCode == OK_200, let json = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		return json.results

	}

}
