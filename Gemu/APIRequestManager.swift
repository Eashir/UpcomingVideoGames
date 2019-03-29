//
//  APIRequestManager.swift
//  Kagami
//
//  Created by Eric Chang on 2/28/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class APIRequestManager {
	
	static let manager = APIRequestManager()
	private init() {}
	
	func getData(endPoint: String, callback: @escaping (Data?) -> Void) {
		guard let myURL = URL(string: endPoint) else { return }
		let session = URLSession(configuration: URLSessionConfiguration.default)
		session.dataTask(with: myURL) { (data: Data?, response: URLResponse?, error: Error?) in
			if error != nil {
				print("Error durring session: \(error)")
			}
			guard let validData = data else { return }
			callback(validData)
			}.resume()
	}
	
	func performRequest(_ method: HTTPMethod, requestURL: String, params: [String: AnyObject], completion: @escaping (_ json: AnyObject?) -> Void) {
		let realm = try! Realm()
		Alamofire.request(requestURL, method: .get, parameters: params, headers: nil).responseJSON { (response:DataResponse<Any>) in
			print(response)
			
			switch(response.result) {
			case .success(_):
				if let data = response.data,
					let validGames = Game.getGames(from: data) {
					for game in validGames {
						try! realm.write {
							realm.add(game)
						}
					}
					//          print("YOUR JSON DATA>>  \(response.data!)")
					completion(nil)
				}
				break
				
			case .failure(_):
				print(response.result.error)
				completion(nil)
				break
			}
			
		}
	}
	
}
