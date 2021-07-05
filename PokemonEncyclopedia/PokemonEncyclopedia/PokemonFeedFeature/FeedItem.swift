//
//  FeedItem.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/06/21.
//

import Foundation

public struct FeedItem: Equatable {
	public let id: UUID
	public let name: String?
	public let imageURL: URL
	
	public init(id: UUID, name: String?, imageURL: URL){
		self.id = id
		self.name = name
		self.imageURL = imageURL
	}
}
