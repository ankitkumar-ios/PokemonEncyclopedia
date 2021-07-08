//
//  LocalFeedItem.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 08/07/21.
//

import Foundation


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
