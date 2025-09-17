//
//  GenericTableWithPlusAndSearch.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/1/25.
//
import UIKit

protocol GenericTableWithHeaderDelegate: AnyObject {
	func setGenericTableWithHeaderView()
	func plusButtonTappedLogic()
	func searchButtonTappedLogic()
}

final class GenericTableWithHeader: UIView {
	weak var delegate: GenericTableWithHeaderDelegate?
	private var contentViewTopAnchor: NSLayoutConstraint?
	private var contentViewBottomAnchor: NSLayoutConstraint?
	private var contentViewLeadingAnchor: NSLayoutConstraint?
	private var contentViewTrailingAnchor: NSLayoutConstraint?
	
	@IBOutlet var contentView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var headerShadowView: UIView!
	@IBOutlet weak var plusButton: UIImageView!
	@IBOutlet weak var searchButton: UIImageView!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var headerLabel: UILabel!
	var hideButtonP: UIButton!
	var initialLoad = true
	
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
		Bundle.main.loadNibNamed("GenericTableWithHeader", owner: self, options: nil)
		addSubview(contentView)
		setHeaderView()
		setContentViewConstraints()
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		if(initialLoad) {
			setContentViewWithInnerShadow(width: contentView.bounds.width, height: contentView.bounds.height)
		}
	}
	@objc func hideButtonTapped() {
		if(hideButtonP.title(for: .normal) == "hide") {
			hideButtonP.setTitle("show", for: .normal)
			self.delegate?.setGenericTableWithHeaderView()
		} else {
			hideButtonP.setTitle("hide", for: .normal)
			print("**delegate \(String(describing: self.delegate))")
			self.delegate?.setGenericTableWithHeaderView()
		}
	}
	@objc func plusButtonTapped() {
		print("**plusButtonTapped")
		print("**delegate \(String(describing: self.delegate))")
		self.delegate?.plusButtonTappedLogic()
	}
	@objc func searchButtonTapped() {
		print("**searchButtonTapped")
		print("**delegate \(String(describing: self.delegate))")
		self.delegate?.searchButtonTappedLogic()
	}
//	Adding an outer shadow
	func setContentViewWithOuterShadow() {
//		setContentViewConstraints()
		
		layer.shadowColor = UIColor.label.cgColor
		layer.shadowOpacity = 0.2
		layer.shadowOffset = .zero
		layer.shadowRadius = 3
		
		shadowView.layer.cornerRadius = 10
		shadowView.layer.masksToBounds = true
		backgroundColor = UIColor.clear
		layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
	}
	func setContentViewConstraints() {
		contentViewTopAnchor?.isActive = false
		let newTopConstraint = contentView.topAnchor.constraint(equalTo: self.topAnchor)
		newTopConstraint.identifier = "contentViewTopAnchor"
		newTopConstraint.isActive = true
		self.contentViewTopAnchor = newTopConstraint
		
		contentViewBottomAnchor?.isActive = false
		let newBottomConstraint = contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		newBottomConstraint.identifier = "contentViewBottomAnchor"
		newBottomConstraint.isActive = true
		self.contentViewTopAnchor = newBottomConstraint
		
		contentViewLeadingAnchor?.isActive = false
		let newLeadingConstraint = contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
		newLeadingConstraint.identifier = "contentViewLeadingAnchor"
		newLeadingConstraint.isActive = true
		self.contentViewLeadingAnchor = newLeadingConstraint
		
		contentViewTrailingAnchor?.isActive = false
		let newTrailingConstraint = contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		newTrailingConstraint.identifier = "contentViewTrailingAnchor"
		newTrailingConstraint.isActive = true
		self.contentViewTrailingAnchor = newTrailingConstraint
	}
	func setContentViewWithInnerShadow(width: CGFloat, height: CGFloat) {
		contentView.clipsToBounds = true
		
		contentView.layer.cornerRadius = 12
		contentView.layer.borderWidth = 1
		contentView.layer.borderColor = newCGColor
		
		let shadowPath = CGMutablePath()
		let inset = -self.innerShadowLayer.shadowRadius * 2.0
		shadowPath.addRect(CGRect(x: inset, y: inset, width: CGFloat(Int(width) - Int(inset*2)), height: CGFloat(Int(height) - Int(inset*2))))
		shadowPath.addRect(CGRect(x: 0, y: 0, width: contentView.bounds.width, height: height))
		self.innerShadowLayer.path = shadowPath
		if(initialLoad) {
			contentView.layer.addSublayer(self.innerShadowLayer)
			initialLoad = false
		}
	}
	func setHeaderView() {
		let gradientLayer = CAGradientLayer()
		let newCGColor = UIColor.label.cgColor.copy(alpha: 0.1)
		gradientLayer.colors = [newCGColor!, UIColor.clear.cgColor]
		gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
		gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
		gradientLayer.frame = headerShadowView.bounds
		headerShadowView.clipsToBounds = true
		headerShadowView.layer.insertSublayer(gradientLayer, at: 0)
	}
	func addHideButton() {
		hideButtonP = UIButton(type: .system)
		hideButtonP.setTitle("hide", for: .normal)
		hideButtonP.setTitleColor(UIColor.link, for: .normal)
		hideButtonP.setTitleColor(UIColor.darkGray, for: .highlighted)
		hideButtonP.backgroundColor = UIColor.clear
		
		hideButtonP.translatesAutoresizingMaskIntoConstraints = false
		
		headerView.addSubview(hideButtonP)
		let hideButtonCenterYConstraint: NSLayoutConstraint = hideButtonP.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
		hideButtonCenterYConstraint.isActive = true
		hideButtonCenterYConstraint.identifier = "hideButtonCenterYConstraint"
		
		let hideButtonTrailingConstraint: NSLayoutConstraint = hideButtonP.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20)
		hideButtonTrailingConstraint.isActive = true
		hideButtonTrailingConstraint.identifier = "hideButtonTrailingConstraint"
		
		hideButtonP.addTarget(self, action: #selector(hideButtonTapped), for: .touchUpInside)
	}
	func addPlusAndSearchButton() {
		let plusButtonP = UIButton()
		plusButtonP.setImage(UIImage(systemName: "plus.circle"), for: .normal)
		plusButtonP.tintColor = UIColor.link
		plusButtonP.backgroundColor = UIColor.clear
		plusButtonP.imageView?.contentMode = .scaleToFill
		plusButtonP.contentHorizontalAlignment = .fill
		plusButtonP.contentVerticalAlignment = .fill
		
		plusButtonP.translatesAutoresizingMaskIntoConstraints = false
		
		headerView.addSubview(plusButtonP)
		let plusButtonCenterYConstraint: NSLayoutConstraint = plusButtonP.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
		plusButtonCenterYConstraint.isActive = true
		plusButtonCenterYConstraint.identifier = "plusButtonCenterYConstraint"
		
		let plusButtonTrailingConstraint: NSLayoutConstraint = plusButtonP.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20)
		plusButtonTrailingConstraint.isActive = true
		plusButtonTrailingConstraint.identifier = "plusButtonTrailingConstraint"
		
		let plusButtonHeightConstraint: NSLayoutConstraint = plusButtonP.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.5)
		plusButtonHeightConstraint.isActive = true
		plusButtonHeightConstraint.identifier = "plusButtonHeightConstraint"
		
		let plusButtonWidthConstraint: NSLayoutConstraint = plusButtonP.widthAnchor.constraint(equalTo: plusButtonP.heightAnchor)
		plusButtonWidthConstraint.isActive = true
		plusButtonWidthConstraint.identifier = "plusButtonWidthConstraint"
		
		let searchButtonP = UIButton()
		searchButtonP.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
		searchButtonP.tintColor = UIColor.link
		searchButtonP.backgroundColor = UIColor.clear
		searchButtonP.imageView?.contentMode = .scaleToFill
		searchButtonP.contentHorizontalAlignment = .fill
		searchButtonP.contentVerticalAlignment = .fill
		
		searchButtonP.translatesAutoresizingMaskIntoConstraints = false
		
		headerView.addSubview(searchButtonP)
		let searchButtonCenterYConstraint: NSLayoutConstraint = searchButtonP.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
		searchButtonCenterYConstraint.isActive = true
		searchButtonCenterYConstraint.identifier = "searchButtonCenterYConstraint"
		
		let searchButtonTrailingConstraint: NSLayoutConstraint = searchButtonP.trailingAnchor.constraint(equalTo: plusButtonP.leadingAnchor, constant: -15)
		searchButtonTrailingConstraint.isActive = true
		searchButtonTrailingConstraint.identifier = "searchButtonTrailingConstraint"
		
		let searchButtonHeightConstraint: NSLayoutConstraint = searchButtonP.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.5)
		searchButtonHeightConstraint.isActive = true
		searchButtonHeightConstraint.identifier = "searchButtonHeightConstraint"
		
		let searchButtonWidthConstraint: NSLayoutConstraint = searchButtonP.widthAnchor.constraint(equalTo: searchButtonP.heightAnchor)
		searchButtonWidthConstraint.isActive = true
		searchButtonWidthConstraint.identifier = "searchButtonWidthConstraint"
		
		plusButtonP.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
		searchButtonP.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
	}
	func addSearchButton() {
		let searchButtonP = UIButton()
		searchButtonP.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
		searchButtonP.tintColor = UIColor.link
		searchButtonP.backgroundColor = UIColor.clear
		searchButtonP.imageView?.contentMode = .scaleToFill
		searchButtonP.contentHorizontalAlignment = .fill
		searchButtonP.contentVerticalAlignment = .fill
		
		searchButtonP.translatesAutoresizingMaskIntoConstraints = false
		
		headerView.addSubview(searchButtonP)
		let searchButtonCenterYConstraint: NSLayoutConstraint = searchButtonP.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
		searchButtonCenterYConstraint.isActive = true
		searchButtonCenterYConstraint.identifier = "searchButtonCenterYConstraint"
		
		let searchButtonTrailingConstraint: NSLayoutConstraint = searchButtonP.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20)
		searchButtonTrailingConstraint.isActive = true
		searchButtonTrailingConstraint.identifier = "searchButtonTrailingConstraint"
		
		let searchButtonHeightConstraint: NSLayoutConstraint = searchButtonP.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.5)
		searchButtonHeightConstraint.isActive = true
		searchButtonHeightConstraint.identifier = "searchButtonHeightConstraint"
		
		let searchButtonWidthConstraint: NSLayoutConstraint = searchButtonP.widthAnchor.constraint(equalTo: searchButtonP.heightAnchor)
		searchButtonWidthConstraint.isActive = true
		searchButtonWidthConstraint.identifier = "searchButtonWidthConstraint"
		searchButtonP.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
	}
}
