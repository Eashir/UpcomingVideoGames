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
    
    parameters = ["api_key":"10466aeae0851fac4b5467674bb3f309ffe650b2" as AnyObject,
                  "filter":"original_release_date:2017-1-1 00:00:00|2018-1-1 00:00:00,platforms:146" as AnyObject,
                  "sort":"original_release_date:desc" as AnyObject,
                  "format":"json" as AnyObject
    ]
    
//    performRequest(.get, requestURL: "https://www.giantbomb.com/api/games/?api_key=10466aeae0851fac4b5467674bb3f309ffe650b2&format=json", params: parameters) { (gameData) in
//    }
  }
  
  
  
}
