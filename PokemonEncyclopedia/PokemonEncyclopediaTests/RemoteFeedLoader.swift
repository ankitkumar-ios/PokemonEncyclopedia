//
//  RemoteFeedLoader.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 12/06/21.
//

import XCTest

class RemoteFeedLoader {
	func load(){
		HTTPClient.shared.requestedURL = URL.init(string: "https://pokeapi.co/api/v2/pokemon/")
	}
}

class HTTPClient{
	static let shared = HTTPClient()
	private init(){}
	
	var requestedURL: URL?
}


class RemoteFeedLoaderTest: XCTestCase {

	func test_init_doesNotRequestDataFromURL(){
		let client = HTTPClient.shared
		let _ = RemoteFeedLoader()
		
		XCTAssertNil(client.requestedURL)
	}


	func test_init_requestDataFromURL(){
		let client = HTTPClient.shared
		let sut = RemoteFeedLoader()
		
		sut.load()
		
		XCTAssertNotNil(client.requestedURL)
	}

	
}
