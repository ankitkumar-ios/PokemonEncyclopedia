//
//  FeedItemMapper.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/06/21.
//

import Foundation

internal final class FeedItemsMapper{
	
	private struct Root: Decodable {
		let results:[Item]
		var feed:[FeedItem] {
			return results.map {$0.item }
		}
	}
	
	private struct Item: Decodable {
		let name: String
		let url: URL
		
		var item: FeedItem {
			FeedItem(name: name, imageURL: url)
		}
	}
	
	
	private static var OK_200: Int {return 200}
	

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result{
		guard response.statusCode == OK_200, let json = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		let items = json.results.map{$0.item}
		return .success(items)

	}

}
