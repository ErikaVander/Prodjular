//
//  CollectionViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 11/11/21.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var StackViewForDotViews: UIStackView!
	@IBOutlet weak var currentDateIndicatorView: UIView!
	//@IBOutlet weak var dotView: UIView!
	//@IBOutlet weak var DotViewContainer: UIView!
	var cellDate: Date?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
