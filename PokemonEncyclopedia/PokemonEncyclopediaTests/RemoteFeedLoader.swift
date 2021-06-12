//
//  RemoteFeedLoader.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 12/06/21.
//

import XCTest

class RemoteFeedLoader {
	let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
	
	func load(){
		client.get(from: URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!)
	}
}

protocol HTTPClient{
	func get(from url: URL) {}
}


class HTTPClientSpy: HTTPClient{
	func get(from url: URL) {
		requestedURL = url
	}
	var requestedURL: URL?
}


class RemoteFeedLoaderTest: XCTestCase {

	func test_init_doesNotRequestDataFromURL(){
		let client = HTTPClientSpy()
		let _ = RemoteFeedLoader(client:client)
		
		XCTAssertNil(client.requestedURL)
	}


	func test_init_requestDataFromURL(){
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(client: client)
		
		sut.load()
		
		XCTAssertNotNil(client.requestedURL)
	}

	
}
