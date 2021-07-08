//
//  RemoteFeedItem.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 08/07/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
	internal let id: UUID
	internal let name: String
	internal let url: URL
}
