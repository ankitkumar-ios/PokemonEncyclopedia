//
//  URLSessionHTTPClientTest.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 12/06/21.
//

import XCTest
import PokemonEncyclopedia

class URLSessionHTTPClient{
	private let session: URLSession
	
	init(session: URLSession) {
		self.session = session
	}
	
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { _, _, error in
			if let error = error {
				completion(.failure(error))
			}
		}.resume()
	}
	
	
}

class URLSessionHTTPClientTest: XCTestCase {
	
	func test_getFromURL_resumeDataTaskWithURL(){
		let url = URL.init(string: "http://anyURL.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		
		
		session.stub(url: url, task: task)
		
		let sut = URLSessionHTTPClient(session: session)
		
		sut.get(from: url) { _ in
			
		}
		
		XCTAssertEqual(task.resumeCallCount, 1)
	}
	
	
	
	func test_getFromURL_failsOnRequestError() {
			let url = URL(string: "http://any-url.com")!
			let error = NSError(domain: "any error", code: 1)
			let session = URLSessionSpy()
			session.stub(url: url, error: error)

			let sut = URLSessionHTTPClient(session: session)

			let exp = expectation(description: "Wait for completion")

			sut.get(from: url) { result in
				switch result {
				case let .failure(receivedError as NSError):
					XCTAssertEqual(receivedError, error)
				default:
					XCTFail("Expected failure with error \(error), got \(result) instead")
				}

				exp.fulfill()
			}

			wait(for: [exp], timeout: 1.0)
		}

	
	
	
	
	
	
	
	//MARK: - HELPER
	private class URLSessionSpy: URLSession {
		private var stubs = [URL: Stubs]()
		private struct Stubs {
			let task: URLSessionDataTask
			let error: Error?
		}
		func stub(url: URL, task: URLSessionDataTaskSpy = URLSessionDataTaskSpy(), error:Error?=nil){
			stubs[url] = Stubs.init(task: task, error: error)
		}
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			guard let stub = stubs[url] else {
				fatalError("could not find stub \(url)")
			}
			completionHandler(nil, nil, stub.error)
			return stub.task
		}
		
	}
	
	private class URLSessionDataTaskSpy: URLSessionDataTask {
		var resumeCallCount = 0
		override func resume() {
			resumeCallCount += 1
		}
	}
	
	
}
