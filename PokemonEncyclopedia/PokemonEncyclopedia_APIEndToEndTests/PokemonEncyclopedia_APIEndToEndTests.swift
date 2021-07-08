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
		switch getFeedResult() {
			case let .success(imageFeed):
				XCTAssertEqual(imageFeed.count, 20, "Expeceted 20 image in test")
				
				imageFeed.enumerated().forEach { (index, item) in
					XCTAssertEqual(item, expectedItem(at: index), "Unexpected Value at index \(index)")
				}
				
			case let .failure(error):
				XCTFail("Expected success but got \(error)")
			default:
				XCTFail("Expected success but got an error")
		}
	}
	
	
	//MARK: Helper
	private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> LoadFeedResult? {
		
		let url = URL.init(string: "https://pokeapi.co/api/v2/pokemon/")!
		let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
		let loader = RemoteFeedLoader(url: url, client: client)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		let ext = expectation(description: "Wait for Completion")
		
		var receivedResult:LoadFeedResult?
		
		loader.load { result in
			receivedResult = result
			ext.fulfill()
		}
		
		wait(for: [ext], timeout: 5.0)
		
		return receivedResult
		
	}
	
	private func expectedItem(at index: Int) -> FeedImage {
		return FeedImage.init(name: name(at: index), url: imageURL(at: index))//URL(string:"https://pokeapi.co/api/v2/pokemon/1/")!
	}
	
	private func name(at index: Int)-> String {
		return [
			"bulbasaur",
			"ivysaur",
			"venusaur",
			"charmander",
			"charmeleon",
			"charizard",
			"squirtle",
			"wartortle",
			"blastoise",
			"caterpie",
			"metapod",
			"butterfree",
			"weedle",
			"kakuna",
			"beedrill",
			"pidgey",
			"pidgeotto",
			"pidgeot",
			"rattata",
			"raticate"
		][index]
	}

	private func imageURL(at index: Int) -> URL {
		return [
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/1/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/2/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/3/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/4/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/5/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/6/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/7/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/8/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/9/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/10/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/11/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/12/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/13/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/14/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/15/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/16/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/17/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/18/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/19/")!,
			URL.init(string: "https://pokeapi.co/api/v2/pokemon/20/")!
		][index]
	}
}
