//
//  RemoteFeedLoader.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 12/06/21.
//

import XCTest

class RemoteFeedLoader {
	func load(){
		HTTPClient.shared.get(from: URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!)
	}
}

class HTTPClient{
	static var shared = HTTPClient()
	
	func get(from url: URL) {}
}


class HTTPClientSpy: HTTPClient{
	override func get(from url: URL) {
		requestedURL = url
	}
	var requestedURL: URL?
}


class RemoteFeedLoaderTest: XCTestCase {

	func test_init_doesNotRequestDataFromURL(){
		let client = HTTPClientSpy()
		HTTPClient.shared = client
		let _ = RemoteFeedLoader()
		
		XCTAssertNil(client.requestedURL)
	}


	func test_init_requestDataFromURL(){
		let client = HTTPClientSpy()
		HTTPClient.shared = client
		let sut = RemoteFeedLoader()
		
		sut.load()
		
		XCTAssertNotNil(client.requestedURL)
	}

	
}
