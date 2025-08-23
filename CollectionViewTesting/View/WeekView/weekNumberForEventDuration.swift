//
//  weekNumberForEventDuration.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 12/14/23.
//

import UIKit

class weekNumberForEventDuration: UICollectionViewCell {
	@IBOutlet weak var selectedBackground: UIView!
	@IBOutlet weak var label: UILabel!
	var cellDate: Date?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func changeBackgroundBlack() {
		selectedBackground.backgroundColor = .black
	}
	
	func changeBackgroundDarkGrey() {
		selectedBackground.backgroundColor = .darkGray
	}
}
