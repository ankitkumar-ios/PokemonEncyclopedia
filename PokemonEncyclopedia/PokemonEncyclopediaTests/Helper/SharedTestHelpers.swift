//
//  SharedTestHelpers.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 11/07/21.
//

import Foundation

func anyNSError() -> NSError{
	return  NSError(domain: "any error", code: 0, userInfo: nil)
}


func anyURL() -> URL{
	return URL.init(string: "http://any-url.com")!
}
