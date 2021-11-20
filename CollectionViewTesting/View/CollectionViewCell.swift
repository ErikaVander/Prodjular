//
//  CollectionViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 11/11/21.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var currentDateIndicatorView: UIView!
	@IBOutlet weak var dotViewContainer: UIView!
	@IBOutlet weak var theDotViewBackgroundView: UIView!
	//@IBOutlet weak var dotView: UIView!
	//@IBOutlet weak var DotViewContainer: UIView!
	var cellDate: Date?
	var arrayOfTheDotViewBackgroundViews = [UIView]()
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
    }
	
	func changeBackgroundBlack() {
		theDotViewBackgroundView.backgroundColor = .black
	}
	
	func changeBackgroundDarkGrey() {
		theDotViewBackgroundView.backgroundColor = .darkGray
	}

}
