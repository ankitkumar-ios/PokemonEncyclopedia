//
//  RemoteFeedLoader.swift
//  PokemonEncyclopediaTests
//
//  Created by Ankit on 12/06/21.
//

import XCTest
import PokemonEncyclopedia


class RemoteFeedLoaderTest: XCTestCase {
	func test_init_doesnotRequestDataFromURL(){
		let (_,client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL(){
		let url = URL(string:"https://new-given-url.com")!
		let (sut,client) = makeSUT(url: url)
		sut.load{ _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	

	func test_loadTwice_requestsDataFromURLTwice(){
		let url = URL(string:"https://new-given-url.com")!
		let (sut,client) = makeSUT(url: url)
		sut.load{ _ in }
		sut.load{ _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	
	func test_load_deliversErrorOnClientError(){
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: failure(.connectivityError)) {
			let clientError = NSError.init(domain: "Test", code: 0, userInfo: nil)
			client.complete(with: clientError)
		}
	}
	
	
	func test_load_deliversErrorOnNo200HTTPResponse(){
		let (sut, client) = makeSUT()
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
				let json = makeItemJSON([])
				client.complete(withStatusCode: code, data: json, at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: failure(.invalidData)) {
			let invalidJSON = Data("InvalidJSON".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		}
		
	}
	
	func test_load_deliverNoItemsOn200HTTPResponseWithEmptyJSONList(){
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: .success([])) {
			let emptyListData = makeItemJSON([])
			client.complete(withStatusCode: 200, data: emptyListData)
		}
	}
	
	func test_load_deliveryItemsOn200HTTPResponseWithJSONItem(){
		let (sut, client) = makeSUT()
		
		let item1 = makeItem(id: UUID(), name: "another name", imageURL: URL.init(string: "https://a-url.com")!)
		let item2 = makeItem(id: UUID(), name: "a name", imageURL: URL.init(string: "https://another-url.com")!)
		
		
		
		expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
			let json = makeItemJSON([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: json)
		}
		
	}

	
	func test_load_doesnotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
		let url = URL(string: "a-url")!
		let client = HTTPClientSpy()
		var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
		
		var captureResult = [RemoteFeedLoader.Result]()
		sut?.load {captureResult.append($0)}
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeItemJSON([]))
		
		XCTAssertTrue(captureResult.isEmpty)
	}
	
	
	//MARK: - Helper
	private func makeSUT(url: URL = URL(string: "https://new-url.com")!, file:StaticString = #file, line:UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		
		return (sut, client)
	}
	
	
	private func makeItem(id: UUID, name: String?,imageURL: URL) -> (model: FeedImage, json:[String: Any]){
		let item = FeedImage(id: id, name: name, url: imageURL)
		let json = [
			"id": item.id?.uuidString,
			"name": item.name,
			"url": item.url.absoluteString,
		].compactMapValues { $0 }
		
		return (item, json)
	}
	
	func makeItemJSON(_ items: [[String: Any]]) -> Data {
		let json = [ "results":items ]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result{
		.failure(error)
	}
	
	private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line:UInt = #line){
		
		
		let exp = expectation(description: "Wait for load completion")
		sut.load {receiveResult in
			switch (receiveResult, expectedResult) {
				case let (.success(receiveItems), .success(expectedItems)):
					XCTAssertEqual(receiveItems, expectedItems, file:file, line: line )
				case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(exprectedError as RemoteFeedLoader.Error)):
						XCTAssertEqual(receivedError, exprectedError, file:file, line: line )
				default:
					XCTFail("expected result \(expectedResult) got receivced result \(receiveResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		wait(for: [exp], timeout: 1.0)
//		XCTAssertEqual(capturedResults, [result], file: file, line: line)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var messages = [(url: URL, completion:(HTTPClientResult)->Void)]()
		
		var requestedURLs: [URL] {
			return messages.map {$0.url}
		}
		
		func get(from url: URL, completion: @escaping (HTTPClientResult)-> Void){
			messages.append((url, completion ))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
			let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
			messages[index].completion(.success(data, response))
		}

	}
	
}
