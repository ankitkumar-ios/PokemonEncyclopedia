//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 19/07/21.
//

import XCTest
import PokemonEncyclopedia


extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
	
	func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let insertionError = insert((feed, timestamp), to: sut)
		
		XCTAssertNotNil(insertionError, "Expect cache insertion error", file: file, line: line)
	}
	
	
	func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .success(nil), file: file, line: line)
	}
	
	
}
