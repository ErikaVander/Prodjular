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
	
	///Was supposed to change the background based on whether or not the cell is selected. However it looks better if the background for theDotViewBackground view is transparent so I commented out the code.
	func changeBackgroundBlack() {
//		theDotViewBackgroundView.backgroundColor = .systemBackground
	}
	///Was supposed to change the background based on whether or not the cell is selected. However it looks better if the background for theDotViewBackground view is transparent so I commented out the code.
	func changeBackgroundDarkGrey() {
//		if self.traitCollection.userInterfaceStyle == .dark {
//			UIView.animate(withDuration: 0, delay: 0) {
//				self.theDotViewBackgroundView.backgroundColor = UIColor.darkGray
//			}
//		} else {
//			UIView.animate(withDuration: 500, delay: 0) {
//				self.theDotViewBackgroundView.layer.backgroundColor = UIColor.lightGray.cgColor
//			}
//		}
	}

}
