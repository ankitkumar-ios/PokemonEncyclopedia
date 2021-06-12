//
//  RemoteFeedLoader.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 12/06/21.
//

import XCTest
import PokemonEncyclopedia


class RemoteFeedLoaderTest: XCTestCase {

	func test_init_doesNotRequestDataFromURL(){
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}


	func test_init_requestDataFromURL(){
		let url = URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURL, url)
	}

	func test_loadTwice_requestDataFromURL(){
		let url = URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url])
		XCTAssertEqual(client.requestedURL, url)
	}

	
	
	//HELPER
	private func makeSUT(url: URL = URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		return (RemoteFeedLoader(url: url, client: client), client)
	}
}



class HTTPClientSpy: HTTPClient{
	var requestedURL: URL?
	var requestedURLs: [URL] = []
	
	func get(from url: URL) {
		requestedURL = url
		requestedURLs.append(url)
	}
}
