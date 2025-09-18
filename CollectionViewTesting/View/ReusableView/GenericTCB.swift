//
//  GenericTCB.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/17/25.
//

import UIKit

protocol GenericTCBDelegate: AnyObject {
	func cellTappedLogic(objectID: String)
	func buttonTappedLogic()
}

class GenericTCB: UITableViewCell {
	weak var delegate: GenericTCBDelegate?
	var objectID: String?
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var labelA: UILabel!
	@IBOutlet weak var labelB: UILabel!
	@IBOutlet weak var labelC: UILabel!
	@IBOutlet weak var rightArrowButton: UIButton!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		setButtonView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setButtonView() {
		rightArrowButton.setTitle("", for: .normal)
	}
    
	@IBAction func cellTapped(_ sender: Any) {
		delegate?.cellTappedLogic(objectID: objectID!)
	}
}
