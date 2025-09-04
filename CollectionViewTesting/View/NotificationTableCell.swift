//
//  NotificationTableCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/2/25.
//

import UIKit

class NotificationTableCell: UITableViewCell {
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var contentLabel: UILabel!
	@IBOutlet weak var headerLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
