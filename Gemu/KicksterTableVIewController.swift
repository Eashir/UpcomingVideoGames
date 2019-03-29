//
//  KicksterTableVIewController.swift
//  Gemu
//
//  Created by Eashir Arafat on 4/25/17.
//  Copyright © 2017 Evan. All rights reserved.
//

import UIKit
//import SwiftyJSON

class KicksterTableVIewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadCustomRefreshContents()
		self.refreshControl?.addTarget(self, action: #selector(KicksterTableVIewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
		
		kicksterLogoImageView.snp.makeConstraints { (make) in
			make.centerX.centerY.equalTo(refreshView)
			make.height.width.equalTo(70)
		}
	}
	
	// MARK: - Methods
	
	func handleRefresh(_ refreshControl: UIRefreshControl) {
		animateKicksterLogo()
		//Please note that if you are refreshing your data asynchronously then you need to move endRefreshing and reloadData calls to your completion handler.
		//http://stackoverflow.com/questions/22059510/uirefreshcontrol-pull-to-refresh-in-ios-7
		self.tableView.reloadData()
		refreshControl.endRefreshing()
	}
	
	func loadCustomRefreshContents() {
		let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
		refreshView = refreshContents?[0] as! UIView
		refreshView.frame = (refreshControl?.bounds)!
		refreshView.addSubview(kicksterLogoImageView)
		refreshControl?.addSubview(refreshView)
	}
	
	func animateKicksterLogo() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse] , animations: {
				self.kicksterLogoImageView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25
				)
			})
			UIView.animate(withDuration: 1, delay: 4, options: [.curveEaseInOut, .repeat, .autoreverse] , animations: {
				self.refreshView.backgroundColor = .red
			})
		}
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		
		cell.detailTextLabel?.text = "Blah"
		
		return cell
	}
	
	//MARK: - Lazy Vars
	
	lazy var refreshView: UIView = {
		var view: UIView = UIView()
		return view
	}()
	
	lazy var kicksterLogoImageView: UIImageView = {
		var imageView: UIImageView = UIImageView()
		imageView.image = UIImage(named: "Kickster 2017 Logo Red Copy")
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
}
