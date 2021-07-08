//
//  LocalFeedItem.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 08/07/21.
//

import Foundation


public struct LocalFeedImage: Equatable {
	public let id: UUID
	public let name: String?
	public let url: URL
	
	public init(id: UUID, name: String?, url: URL){
		self.id = id
		self.name = name
		self.url = url
	}
}
