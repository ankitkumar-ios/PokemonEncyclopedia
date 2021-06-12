//
//  FeedItem.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/06/21.
//

import Foundation

public struct FeedItem: Equatable {
	public let name: String?
	public let imageURL: URL
	
	public init(name: String?, imageURL: URL){
		self.name = name
		self.imageURL = imageURL
	}
}
