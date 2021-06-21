//
//  PokemonEncyclopedia_APIEndToEndTests.swift
//  PokemonEncyclopedia_APIEndToEndTests
//
//  Created by Ankit on 21/06/21.
//

import XCTest
import PokemonEncyclopedia

class PokemonEncyclopedia_APIEndToEndTests: XCTestCase {

	func test_endToEndTestServerGETFeedResult_matchFixedTestAccountData() {
		let url = URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!
		let client = URLSessionHTTPClient()
		let loader = RemoteFeedLoader(url: url, client: client)
		
		let ext = expectation(description: "Wait for Completion")
		
		var receivedResult:LoadFeedResult?
		
		loader.load { result in
			receivedResult = result
			ext.fulfill()
		}
		
		wait(for: [ext], timeout: 5.0)
		
		switch receivedResult {
			case let .success(items):
				XCTAssertEqual(items.count, 20, "Expeceted 8 items")
			case let .failure(error):
				XCTFail("Exptected success but got \(error)")
			default:
				XCTFail("Exptected success but got \(String(describing: receivedResult))")
		}
		
		
	}


}
