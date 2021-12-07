//
//  TableViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 11/11/21.
//

import UIKit

class TableViewCell: UITableViewCell {
	
	@IBOutlet weak var EventLabel: UILabel!
	@IBOutlet weak var TimeLabel: UILabel!
	@IBOutlet weak var ViewInTableViewCell: UIView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
