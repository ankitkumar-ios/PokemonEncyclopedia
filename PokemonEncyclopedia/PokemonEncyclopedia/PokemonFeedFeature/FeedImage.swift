//
//  FeedItem.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/06/21.
//

import Foundation

public struct FeedImage: Equatable {
	public let id: UUID?
	public let name: String?
	public let url: URL
	
	public init(id: UUID?=nil, name: String?, url: URL){
		self.id = id
		self.name = name
		self.url = url
	}
}
