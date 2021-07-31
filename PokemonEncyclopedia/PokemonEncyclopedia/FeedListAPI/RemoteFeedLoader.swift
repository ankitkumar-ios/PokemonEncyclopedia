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
	
	public typealias Result = FeedLoader.Result
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result)-> Void) {
		client.get(from:url) {[weak self] result in
			guard self != nil else {return}
			switch result {
				case let .success(data, response):
					completion(RemoteFeedLoader.map(data, from: response))
				case .failure:
					completion(.failure(Error.connectivityError))
			}
		}
	}
	
	private static func map(_ data:Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedItemsMapper.map(data, from: response)
			return .success(items.toModels())
		}catch {
			return .failure(error)
		}
	}
	
}

private extension Array where Element == RemoteFeedItem {
	func toModels() -> [FeedImage] {
		return map { FeedImage(id: $0.id, name: $0.name, url: $0.url) }
	}
}
