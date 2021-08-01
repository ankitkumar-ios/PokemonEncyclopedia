//
//  HTTPClient.swift
//  PokemonEncyclopedia
//
//  Created by Ankit on 12/06/21.
//

import Foundation


public protocol HTTPClient {
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed
	
	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
	
	func get(from url: URL, completion: @escaping (Result)->Void)
}
