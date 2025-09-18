//
//  GenericTCA.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/4/25.
//

import UIKit

protocol GenericTCADelegate: AnyObject {
	func cellTappedLogic(objectID: String)
	func buttonTappedLogic()
}

class GenericTCA: UITableViewCell {
	weak var delegate: GenericTCADelegate?
	var objectID: String?
	@IBOutlet weak var rightArrow: UIButton!
	@IBOutlet weak var button: UIButton!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var labelA: UILabel!
	@IBOutlet weak var labelB: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	@IBAction func cellTapped(_ sender: Any) {
		delegate?.cellTappedLogic(objectID: objectID!)
	}
	@IBAction func buttonTapped(_ sender: Any) {
		delegate?.buttonTappedLogic()
	}
	
	func hideButtonView() {
		button.isHidden = true
	}
	func showButtonView() {
		button.isHidden = false
		button.layer.cornerRadius = 12
	}
	func showRightArrowButton() {
		rightArrow.isHidden = false
		rightArrow.setImage(UIImage(systemName: "chevron.right"), for: .normal)
		rightArrow.setTitle("", for: .normal)
	}
	func hideRightArrowButton() {
		rightArrow.isHidden = true
	}
}
