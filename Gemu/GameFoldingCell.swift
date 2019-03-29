//
//  DemoCell.swift
//  FoldingCell
//
//  Created by Alex K. on 25/12/15.
//  Copyright © 2015 Alex K. All rights reserved.
//

import UIKit
import FoldingCell

class GameFoldingCell: FoldingCell {
	
	@IBOutlet weak var gameImage: UIImageView!
	@IBOutlet weak var gameName: UILabel!
	@IBOutlet weak var gameDescription: UILabel!
	
	override func awakeFromNib() {
		
		gameImage.contentMode = .scaleToFill
		foregroundView.layer.cornerRadius = 10
		foregroundView.layer.masksToBounds = true
		itemCount = 3
		self.backViewColor = ColorPalette.grayColor
		
		super.awakeFromNib()
	}
	
	override func prepareForReuse() {
		gameName.text = nil
		gameDescription.text = nil
		gameImage.image = nil
	}
	
	override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
		let durations = [0.26, 0.2, 0.2]
		return durations[itemIndex]
	}
	
}
