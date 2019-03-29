//
//  Game.swift
//  Gemu
//
//  Created by Eashir Arafat on 4/8/17.
//  Copyright © 2017 Evan. All rights reserved.
//

import Foundation
import RealmSwift

enum GameParseError: Error {
  case response, name, image, description
}

class Game: Object {
  dynamic var name: String? = nil
  dynamic var image: String? = nil
  dynamic var descrip: String? = nil
  
  static func getGames(from data: Data?) -> [Game]? {
    var games: [Game]? = []
    
    do {
      let jsonData = try JSONSerialization.jsonObject(with: data!, options: [])
      guard let response = jsonData as? [String: Any],
        let results = response["results"] as? [[String: Any]]
        else { throw GameParseError.response }
      
      for game in results {
        let validGame = Game()
        var description: String? = nil
        var image: String? = nil
        
        guard let name = game["name"] as? String
          else { throw GameParseError.name }
        
        if let desc = game["deck"] as? String {
          description = desc
        }
        if let images = game["image"] as? [String: Any],
          let imagee = images["super_url"] as? String {
          image = imagee
        }
        
        validGame.image = image
        validGame.name = name
        validGame.descrip = description
        
        games?.append(validGame)
      }
      return games
    }
    catch {
      print("Problem casting json: \(error)")
    }
    return nil
  }
}




