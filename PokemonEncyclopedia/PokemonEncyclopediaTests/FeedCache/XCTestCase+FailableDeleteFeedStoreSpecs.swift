//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 19/07/21.
//

import XCTest
import PokemonEncyclopedia

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
	
	func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let deletionError = deleteCache(from: sut)

		XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
	}
	
	
	func assertThatDeletehasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		deleteCache(from: sut)

		expect(sut, toRetrieve: .success(nil), file: file, line: line)
	}
	
}
