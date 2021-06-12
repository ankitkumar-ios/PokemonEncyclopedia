//
//  RemoteFeedLoader.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/06/21.
//

import Foundation

public final class RemoteFeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivityError
		case invalidData
	}
	
	public typealias Result = LoadFeedResult
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result)-> Void) {
		client.get(from:url) {[weak self] result in
			guard self != nil else {return}
			switch result {
				case let .success(data, response):
					completion(FeedItemsMapper.map(data, from: response))
				case .failure:
					completion(.failure(Error.connectivityError))
			}
		}
	}
	
}
