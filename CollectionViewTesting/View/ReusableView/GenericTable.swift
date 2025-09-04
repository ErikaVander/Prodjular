//
//  GenericTable.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/2/25.
//

import UIKit

class GenericTable: UIView {
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var contentView: UIView!
	
	let newCGColor = UIColor.label.cgColor.copy(alpha: 0.06)
	
	lazy var innerShadowLayer: CAShapeLayer = {
		let shadowLayer = CAShapeLayer()
		shadowLayer.shadowColor = UIColor.black.cgColor
		shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
		shadowLayer.shadowOpacity = 0.1
		shadowLayer.shadowRadius = 1.5
		shadowLayer.fillRule = .evenOdd
		return shadowLayer
	}()
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	private func commonInit() {
		Bundle.main.loadNibNamed("GenericTable", owner: self, options: nil)
		addSubview(contentView)
		setContentViewWithInnerShadow()
	}
	//	Adding an outer shadow
	func setContentViewWithOuterShadow() {
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		
		layer.shadowColor = UIColor.label.cgColor
		layer.shadowOpacity = 0.2
		layer.shadowOffset = .zero
		layer.shadowRadius = 3
		
		shadowView.layer.cornerRadius = 10
		shadowView.layer.masksToBounds = true
		backgroundColor = UIColor.clear
		layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
	}
	func setContentViewWithInnerShadow() {
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		
		contentView.clipsToBounds = true
		
		contentView.layer.cornerRadius = 12
		contentView.layer.addSublayer(self.innerShadowLayer)
		contentView.layer.borderWidth = 1
		contentView.layer.borderColor = newCGColor
	}
}
