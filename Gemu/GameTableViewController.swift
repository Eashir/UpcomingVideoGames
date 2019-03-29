//
//  DemoTableViewController.swift
//  FoldingCellProgrammatically
//
//  Created by Alex K. on 09/06/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit
import FoldingCell
import RealmSwift
import Lottie
import SnapKit

class GameTableViewController: UITableViewController {
  
  let kCloseCellHeight: CGFloat = 179
  let kOpenCellHeight: CGFloat = 488
  let kRowsCount = 10
  let realm = try! Realm()
  
  var cellHeights = [CGFloat]()
  var games: [Game] = []
  
  var task: URLSessionDownloadTask!
  var session: URLSession!
  var cache: NSCache<AnyObject, AnyObject>!
  
  var kicksterRefreshControl: PullToKickster!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = ColorPalette.grayColor
    
    getGameObjects()
    createCellHeightsArray()
    setupCache()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    kicksterRefreshControl = PullToKickster(at: .top)
    
    let parameters = ["api_key":"10466aeae0851fac4b5467674bb3f309ffe650b2" as AnyObject,
                  "filter":"original_release_date:2017-1-1 00:00:00|2018-1-1 00:00:00,platforms:146" as AnyObject,
                  "sort":"original_release_date:desc" as AnyObject,
                  "format":"json" as AnyObject
    ]
    
    self.tableView.addPullToRefresh(kicksterRefreshControl)  {
      APIRequestManager.manager.performRequest(.get, requestURL: "https://www.giantbomb.com/api/games/?api_key=10466aeae0851fac4b5467674bb3f309ffe650b2&format=json", params: parameters) { (gameData) in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.tableView.reloadData()
          self.tableView.endRefreshing(at: .top)
        }
      }
      
//      APIRequestManager.manager.performRequest(.get, requestURL: "http://208.68.37.139/checkImageCategory", params: ["post_id": "Test001" as AnyObject, "image":"http://www.runnersworld.com/sites/runnersworld.com/files/styles/slideshow-desktop/public/nike_vomero_m_400.jpg" as AnyObject], completion: { (data) in
//        print("DONE")
//      })
    }
    
  }
  
  // MARK: - Configure
  func createCellHeightsArray() {
    for _ in 0...games.count {
      cellHeights.append(kCloseCellHeight)
    }
  }
  
  func getGameObjects() {
    let allGames = realm.objects(Game.self)
    for game in allGames {
      games.append(game)
    }
  }
  
  func setupCache() {
    session = URLSession.shared
    task = URLSessionDownloadTask()
    self.cache = NSCache()
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return games.count
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    guard case let cell as GameFoldingCell = cell else {
      return
    }
    
    cell.backgroundColor = UIColor.clear
    
    if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
      cell.selectedAnimation(false, animated: false, completion:nil)
    } else {
      cell.selectedAnimation(true, animated: false, completion: nil)
    }
    cell.alpha = 0.5
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! GameFoldingCell
    
    let game = games[indexPath.row]
    
    guard game.image != nil else {
      return cell
    }
    
    if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil){
      cell.gameImage?.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
    }
    else {

      let imageURL = game.image
      let url:URL! = URL(string: imageURL!)
      task = session.downloadTask(with: url, completionHandler: { (locationURL, response, error) -> Void in
        if let data = try? Data(contentsOf: url){
          DispatchQueue.main.async(execute: { () -> Void in
            if let updateCell = tableView.cellForRow(at: indexPath) as? GameFoldingCell{
              let img:UIImage! = UIImage(data: data)
              updateCell.gameImage?.image = img
              self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject)
            }
          })
        }
      })
      task.resume()
    }
    
    cell.gameName.text = game.name
    cell.gameDescription.text = game.descrip
    cell.backgroundColor = .black
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeights[(indexPath as NSIndexPath).row]
  }
  
  // MARK: Table view delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
    
    if cell.isAnimating() {
      return
    }
    
    var duration = 0.0
    if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight { // open cell
      cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
      cell.selectedAnimation(true, animated: true, completion: nil)
      duration = 0.5
    } else {// close cell
      cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
      cell.selectedAnimation(false, animated: true, completion: nil)
      duration = 0.8
    }
    
    UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
      tableView.beginUpdates()
      tableView.endUpdates()
    }, completion: nil)
  }

}
