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
			
		}.resume()
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
	
	func test_getFromURL_resumeDataTaskWithURL(){
		let url = URL.init(string: "http://anyURL.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		
		
		session.stub(url: url, task: task)
		
		let sut = URLSessionHTTPClient(session: session)
		
		sut.get(from: url)
		
		XCTAssertEqual(task.resumeCallCount, 1)
	}
	
	
	//MARK: - HELPER
	private class URLSessionSpy: URLSession {
		var receivedURLs = [URL]()
		private var stub = [URL: URLSessionDataTask]()
		
		func stub(url: URL, task: URLSessionDataTaskSpy){
			stub[url] = task
		}
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			receivedURLs.append(url)
			return stub[url] ?? URLSessionDataTaskSpy()
		}
		
	}
	
	private class URLSessionDataTaskSpy: URLSessionDataTask {
		var resumeCallCount = 0
		override func resume() {
			resumeCallCount += 1
		}
	}
	
	
}
