//
//  CollectionViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/9/21.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    var eventsForThisCell = [Event]()
	var monthDate: Date!
	
	@IBOutlet weak var label: UILabel!

}
