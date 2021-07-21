//
//  CoreDataFeedStoreTests.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 21/07/21.
//

import XCTest
import PokemonEncyclopedia


class CoreDataFeedStoreSpecs: XCTestCase, FeedStoreSpecs {
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveHasNoSideEffectOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
//		let sut = makeSUT()
		
//		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() {
		
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() {
		
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() {
		
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() {
		
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() {
		
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		
	}
	
	func test_storeSideEffects_runSerially() {
		
	}
	
	//MARK:- Helper
	
	private func makeSUT(file:StaticString = #file, line: UInt = #line) -> FeedStore{
		let sut = CoreDataFeedStore()
		trackForMemoryLeaks(sut)
		return sut
	}
	
}
