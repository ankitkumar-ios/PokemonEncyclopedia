//
//  URLSessionHTTPClientTest.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 12/06/21.
//

import XCTest

class URLSessionHTTPClient{
	private let session: URLSession
	
	init(session: URLSession) {
		self.session = session
	}
	
	func get(from url: URL){
		session.dataTask(with: url) { _, _, _ in
			
		}
	}
	
	
}

class URLSessionHTTPClientTest: XCTestCase {
	
	func test_getFromURL_createDataTaskWithURL(){
		
		let url = URL.init(string: "http://anyURL.com")!
		let session = URLSessionSpy()
		
		let sut = URLSessionHTTPClient(session: session)
		
		sut.get(from: url)
		
		XCTAssertEqual(session.receivedURLs, [url])
	}
	
	
	//MARK: - HELPER
	private class URLSessionSpy: URLSession {
		var receivedURLs = [URL]()
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			receivedURLs.append(url)
			return URLSessionDataTaskSpy()
		}
		
	}
	
	private class URLSessionDataTaskSpy: URLSessionDataTask {
		
	}
	
	
}
