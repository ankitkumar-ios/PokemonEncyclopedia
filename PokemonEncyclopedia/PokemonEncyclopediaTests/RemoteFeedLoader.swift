//
//  RemoteFeedLoader.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 12/06/21.
//

import XCTest

class RemoteFeedLoader {
	let client: HTTPClient
	let url: URL
	
	init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	func load(){
		client.get(from: URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!)
	}
}

protocol HTTPClient{
	func get(from url: URL)
}


class HTTPClientSpy: HTTPClient{
	func get(from url: URL) {
		requestedURL = url
	}
	var requestedURL: URL?
}


class RemoteFeedLoaderTest: XCTestCase {

	func test_init_doesNotRequestDataFromURL(){
		let url = URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!
		let client = HTTPClientSpy()
		let _ = RemoteFeedLoader(url:url, client:client)
		
		XCTAssertNil(client.requestedURL)
	}


	func test_init_requestDataFromURL(){
		let url = URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURL, url)
	}

	
}
