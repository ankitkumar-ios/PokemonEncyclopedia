//
//  CodableFeedStoreTests.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 14/07/21.
//

import XCTest
import PokemonEncyclopedia

class CodableFeedStore {
	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		completion(.empty)
	}
}

class CodableFeedStoreTests: XCTestCase {

	func test_retrieve_deliversEmptyOnEmptyCache(){
		let sut = CodableFeedStore()
		let exp = expectation(description: "Wait for completion")
		
		sut.retrieve{ result in
			switch result {
				case .empty:
					break
				default:
					XCTFail("Expected empty result, got \(result) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
}
