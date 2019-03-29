//
//  GameViewController.swift
//  Gemu
//
//  Created by Eashir Arafat on 4/8/17.
//  Copyright © 2017 Evan. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class GameViewController: UIViewController {
	var endPoint = String()
	var games = [Game]()
	var parameters = [String:AnyObject]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .blue

		parameters = [
			"api_key":"10466aeae0851fac4b5467674bb3f309ffe650b2" as AnyObject,
			"filter":"original_release_date:2019-1-1 00:00:00|2019-3-27 00:00:00,platforms:146" as AnyObject,
			"sort":"original_release_date:desc" as AnyObject,
			"format":"json" as AnyObject
		]
		
		performRequest(.get, requestURL: "https://www.giantbomb.com/api/games/?api_key=10466aeae0851fac4b5467674bb3f309ffe650b2&format=json", params: parameters) { (gameData) in
		}
	}
	
	func performRequest(_ method: HTTPMethod, requestURL: String, params: [String: AnyObject], completion: @escaping (_ json: AnyObject?) -> Void) {
		let realm = try! Realm()
		try! realm.write {
			realm.deleteAll()
		}
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
					print("YOUR JSON DATA>>  \(response.data!)")
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
