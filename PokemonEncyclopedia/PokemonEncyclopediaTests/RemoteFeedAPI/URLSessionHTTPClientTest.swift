//
//  URLSessionHTTPClientTest.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 12/06/21.
//

import XCTest
import PokemonEncyclopedia

protocol HTTPSession {
	func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
	func resume()
}

class URLSessionHTTPClient{
	private let session: HTTPSession
	
	init(session: HTTPSession) {
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
		let session = HTTPSessionSpy()
		let task = HTTPSessionTaskSpy()
		
		
		session.stub(url: url, task: task)
		
		let sut = URLSessionHTTPClient(session: session)
		
		sut.get(from: url) { _ in
			
		}
		
		XCTAssertEqual(task.resumeCallCount, 1)
	}
	
	
	
	func test_getFromURL_failsOnRequestError() {
			let url = URL(string: "http://any-url.com")!
			let error = NSError(domain: "any error", code: 1)
			let session = HTTPSessionSpy()
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
	private class HTTPSessionSpy: HTTPSession {
		
		private var stubs = [URL: Stubs]()
		private struct Stubs {
			let task: HTTPSessionTask
			let error: Error?
		}
		func stub(url: URL, task: HTTPSessionTask = HTTPSessionTaskSpy(), error:Error?=nil){
			stubs[url] = Stubs.init(task: task, error: error)
		}
		
		func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
			guard let stub = stubs[url] else {
				fatalError("could not find stub \(url)")
			}
			completionHandler(nil, nil, stub.error)
			return stub.task
		}
		
	}
	
	private class HTTPSessionTaskSpy: HTTPSessionTask {
		var resumeCallCount = 0
		 func resume() {
			resumeCallCount += 1
		}
	}
	
	
}
