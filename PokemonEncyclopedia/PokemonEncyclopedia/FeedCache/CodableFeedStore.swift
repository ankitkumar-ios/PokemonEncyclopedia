//
//  CodableFeedStore.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 17/07/21.
//

import Foundation

public class CodableFeedStore: FeedStore {
	
	private struct Cache: Codable {
		var feed: [CodableFeedImage]
		var timestamp: Date
		
		var localFeed: [LocalFeedImage] {
			return feed.map { $0.local }
		}
	}
	
	private struct CodableFeedImage: Codable {
		private let id: UUID?
		private let name: String?
		private let url: URL
		
		init(_ image:LocalFeedImage) {
			self.id = image.id
			self.name = image.name
			self.url = image.url
			
		}
		
		var local: LocalFeedImage {
			return LocalFeedImage(id: id, name: name, url: url)
		}
	}
	
	private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
	private var storeURL: URL
	public init(storeURL: URL) {
		self.storeURL = storeURL
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let storeURL = self.storeURL
		queue.async {
			guard let data = try? Data(contentsOf: storeURL) else{
				return completion(.empty)
			}
			do {
				let decoder = JSONDecoder()
				let cache = try decoder.decode(Cache.self, from: data)
				completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
			}
			catch{
				completion(.failure(error))
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let storeURL = self.storeURL
		queue.async(flags: .barrier) {
			do {
				let encoder = JSONEncoder()
				let cache = Cache(feed: feed.map( CodableFeedImage.init ), timestamp: timestamp)
				let encoded = try encoder.encode(cache)
				try encoded.write(to: storeURL)
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion){
		let storeURL = self.storeURL
		queue.async(flags: .barrier) {
			guard FileManager.default.fileExists(atPath: storeURL.path) else {
				return completion(nil)
			}
			
			do {
				try FileManager.default.removeItem(at: storeURL)
				completion(nil)
			}
			catch{
				completion(error)
			}
		}
	}
}
