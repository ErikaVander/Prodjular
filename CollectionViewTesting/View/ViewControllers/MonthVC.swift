//
//  monthVC.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 10/7/25.
//

import UIKit

class MonthVC: UIViewController {
	var selectedDate = plusDay(date: currentDateAndTime())
	var eventID: String?
	var event: ProjdularEvent?
	@IBOutlet weak var eventNameLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var yearLabel: UILabel!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var submitButton: UIButton!
	override func viewDidLoad() {
        super.viewDidLoad()
		collectionView.allowsMultipleSelection = true
		collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
		//Setting up the collectionView delegate and datasource
		collectionView.delegate = self
		collectionView.dataSource = self
		setCollectionViewLayout()
		fillMonth(parDate: event!.startDate!)
		setViews()
    }
	
	@IBAction func goBack(_ sender: Any) {
		EventService.shared.stopObserving()
		self.dismiss(animated: true)
	}
	@IBAction func goHome(_ sender: Any) {
		EventService.shared.stopObserving()
		self.view.window?.rootViewController?.dismiss(animated: true)
	}
	
	func setViews() {
		backButton.setTitle("", for: .normal)
		///Setting the month and year label
		print("**event.startdate: \(String(describing: event!.startDate!))")
		monthLabel.text = monthString(date: event!.startDate!)
		yearLabel.text = yearString(date: event!.startDate!)
		////Setting Event Name
		eventNameLabel.text = event?.nameOfEvent
		submitButton.layer.cornerRadius = 10
	}
}

extension MonthVC: UICollectionViewDataSource {
	///The number of sections in the month collectionView calendar
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	///The number of items in each section is determined by the lengthe of nums[] which keeps track of the content that will be added to the collectionView
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		print("--num.count = ", numMonth.count)
		return numMonth.count
	}
	
	///Makes sure that only cells containing numbers can be selected by the user. Sets the default background view for selected cells. Sets each cells label to the elements within nums[] which keeps track of the content that will be added to the collectionView. Creates dotViews for cells that have events.
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
		
		cellOne.isUserInteractionEnabled = false
		cellOne.currentDateIndicatorView.isHidden = true
		cellOne.label.textColor = .label
		cellOne.theDotViewBackgroundView.isHidden = true
		for subviews in cellOne.theDotViewBackgroundView.subviews {
			subviews.removeFromSuperview()
		}
		
		if Int(numMonth[indexPath.item]) != nil {
			cellOne.automaticallyUpdatesBackgroundConfiguration = true
			cellOne.isUserInteractionEnabled = true
			
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MMM"
			
			let formatterTwo = DateFormatter()
			formatterTwo.dateFormat = "yyyy-MMM-dd"
			
			let firstPartOfDate = formatter.string(from: event!.startDate!)
			let dateString = "\(firstPartOfDate)-\(numMonth[indexPath.item])"
			
			let theDate = formatterTwo.date(from: dateString) ?? formatterTwo.date(from: "2020-August-21")!
			
			if indexPath.item <= 49 {
				cellOne.cellDate = theDate
				if(formatterTwo.string(from: cellOne.cellDate!) == formatterTwo.string(from: currentDateAndTime())){
					if formatterTwo.string(from: cellOne.cellDate!) == formatterTwo.string(from: selectedDate) {
						cellOne.currentDateIndicatorView.layer.borderColor = UIColor.white.cgColor
					} else {
						
						if self.traitCollection.userInterfaceStyle == .light {
							
							cellOne.currentDateIndicatorView.layer.borderColor = UIColor.darkGray.cgColor
						}
					}
					cellOne.currentDateIndicatorView.layer.borderWidth = 2
					cellOne.currentDateIndicatorView.layer.cornerRadius = 5
					cellOne.currentDateIndicatorView.isHidden = false
				}
			} else if indexPath.item <= 98 {
				cellOne.cellDate = plusmonth(date: theDate)
				if(formatterTwo.string(from: cellOne.cellDate!) == formatterTwo.string(from: currentDateAndTime())) {
					
					if formatterTwo.string(from: cellOne.cellDate!) != formatterTwo.string(from: selectedDate) {
						
						cellOne.currentDateIndicatorView.layer.borderColor = UIColor.white.cgColor
					} else {
						
						if self.traitCollection.userInterfaceStyle == .light {
							
							cellOne.currentDateIndicatorView.layer.borderColor = UIColor.darkGray.cgColor
						}
					}
					cellOne.currentDateIndicatorView.layer.borderWidth = 2
					cellOne.currentDateIndicatorView.layer.cornerRadius = 5
					cellOne.currentDateIndicatorView.isHidden = false
				}
			}
			
			if(EventService.shared.eventsForDate(parDate: theDate).count != 0 && cellOne.cellDate == theDate) {
				cellOne.theDotViewBackgroundView.isHidden = false
				
				for events in EventService.shared.eventsForDate(parDate: theDate) {
					let dotViewWidth: CGFloat = 4
					let dotViewHeight: CGFloat = 4
					
					let dotView = UIView(frame: CGRect(x: 0, y: 0, width: dotViewWidth, height: dotViewHeight))
					
					//Set the dotview color to the user selected color
					dotView.backgroundColor = UIColor(named: "\(events.tagColor!)")
					dotView.layer.cornerRadius = dotViewWidth/3
					
					cellOne.theDotViewBackgroundView.addSubview(dotView)
					
					cellOne.theDotViewBackgroundView.translatesAutoresizingMaskIntoConstraints = false
					dotView.translatesAutoresizingMaskIntoConstraints = false
					
					//Changes the background based on whether or not the cell is selected, and whether or not it is the current date. If it isn't the current date, theDotViewBackgroundView will not have a background, if it is the current date, theDotViewBackgroundView will have background so that it is not hidden from the currentDateIndicator.
					if (formatterTwo.string(from: theDate) == formatterTwo.string(from: selectedDate) && formatterTwo.string(from: theDate) == formatterTwo.string(from: currentDateAndTime())) {
						cellOne.changeBackgroundDarkGrey()
					} else if formatterTwo.string(from: theDate) == formatterTwo.string(from: currentDateAndTime()) {
						cellOne.changeBackgroundBlack()
					} else {
						cellOne.changeBackgroundTransparent()
					}
					
					cellOne.theDotViewBackgroundView.layer.cornerRadius = 4
					
					//If statement for setting up theDotViewBackgroundView
					var widthMultiplier: CGFloat = 0
					if EventService.shared.eventsForDate(parDate: theDate).count <= 4 {
						widthMultiplier = CGFloat(EventService.shared.eventsForDate(parDate: theDate).count)
						
						let theDotViewBackgroundBottomConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.bottomAnchor.constraint(equalTo: cellOne.label.bottomAnchor, constant: 7)
						theDotViewBackgroundBottomConstraint.isActive = true
						theDotViewBackgroundBottomConstraint.identifier = "theDotViewBackground-Bottom"
						
						let theDotViewBackgroundViewHeightConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.heightAnchor.constraint(equalTo: dotView.heightAnchor, constant: dotViewHeight)
						theDotViewBackgroundViewHeightConstraint.isActive = true
						theDotViewBackgroundViewHeightConstraint.identifier = "theDotViewBackgroundView-Height-Constraint"
						
						let dotViewYConstraint: NSLayoutConstraint = dotView.centerYAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.centerYAnchor)
						dotViewYConstraint.isActive = true
						dotViewYConstraint.identifier = "dotView-Y-Constraint"
						
					} else {
						widthMultiplier = 4
						
						let theDotViewBackgroundBottomConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.bottomAnchor.constraint(equalTo: cellOne.label.bottomAnchor, constant: 7)
						theDotViewBackgroundBottomConstraint.isActive = true
						theDotViewBackgroundBottomConstraint.identifier = "theDotViewBackground-Bottom"
						
						let theDotViewBackgroundViewHeightConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.heightAnchor.constraint(equalTo: dotView.heightAnchor, multiplier: 2, constant: (dotViewHeight*2)-2)
						theDotViewBackgroundViewHeightConstraint.isActive = true
						theDotViewBackgroundViewHeightConstraint.identifier = "theDotViewBackgroundView-Height-Constraint"
						
						let dotViewYConstraint: NSLayoutConstraint = dotView.bottomAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.bottomAnchor, constant: -2)
						dotViewYConstraint.isActive = true
						dotViewYConstraint.identifier = "dotView-Y-Constraint"
					}
					
					let dotViewWidthConstraint = dotView.widthAnchor.constraint(equalToConstant: dotViewWidth)
					dotViewWidthConstraint.isActive = true
					dotViewWidthConstraint.identifier = "dotView-Width-Constraint"
					
					let dotViewHeightConstaint = dotView.heightAnchor.constraint(equalToConstant: dotViewHeight)
					dotViewHeightConstaint.isActive = true
					dotViewHeightConstaint.identifier = "dotView-Height-Constraint"
					
					let theDotViewBackgroundViewWidthConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.widthAnchor.constraint(equalTo: dotView.widthAnchor, multiplier: CGFloat(widthMultiplier), constant: 2*CGFloat((widthMultiplier+1)))
					theDotViewBackgroundViewWidthConstraint.isActive = true
					theDotViewBackgroundViewWidthConstraint.identifier = "theDotViewBackgroundView-Width-Constraint"
					
					//For non-centered: cellOne.theDotViewBackgroundView.leadingAnchor.constraint(equalTo: cellOne.leadingAnchor, constant: 7)
					let theDotViewBackgroundViewLeadingConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.centerXAnchor.constraint(equalTo: cellOne.centerXAnchor, constant: 0)
					theDotViewBackgroundViewLeadingConstraint.isActive = true
					theDotViewBackgroundViewLeadingConstraint.identifier = "theDotViewBackgroundView-Leading-Constraint"
					
					//If Statement to determine the leading constraint of dotView.
					if cellOne.theDotViewBackgroundView.subviews.count == 1 {
						let dotViewLeadingConstraint: NSLayoutConstraint = dotView.leadingAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.leadingAnchor, constant: 2)
						dotViewLeadingConstraint.isActive = true
						dotViewLeadingConstraint.identifier = "dotView-X-Constraint"
						
					} else if cellOne.theDotViewBackgroundView.subviews.count <= 4 {
						let dotViewLeadingConstraint: NSLayoutConstraint = dotView.leadingAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews[0].leadingAnchor, constant: CGFloat((cellOne.theDotViewBackgroundView.subviews.count)-1)*(dotView.frame.width+2))
						dotViewLeadingConstraint.isActive = true
						dotViewLeadingConstraint.identifier = "dotView-X-Constraint"
						
					} else if cellOne.theDotViewBackgroundView.subviews.count == 5 {
						let dotViewLeadingConstraint: NSLayoutConstraint = dotView.leadingAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews.first!.leadingAnchor, constant: -1)
						dotViewLeadingConstraint.isActive = true
						dotViewLeadingConstraint.identifier = "dotView-X-Constraint"
						
						let dotViewYConstraint: NSLayoutConstraint = dotView.bottomAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews.first!.topAnchor, constant: -2)
						dotViewYConstraint.isActive = true
						dotViewYConstraint.identifier = "dotView-Y-Constraint"
						
					} else {
						let dotViewLeadingConstraint: NSLayoutConstraint = dotView.leadingAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews[3].leadingAnchor, constant: 1)
						dotViewLeadingConstraint.isActive = true
						dotViewLeadingConstraint.identifier = "dotView-X-Constraint"
						
						let dotViewYConstraint: NSLayoutConstraint = dotView.bottomAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews.first!.topAnchor, constant: -2)
						dotViewYConstraint.isActive = true
						dotViewYConstraint.identifier = "dotView-Y-Constraint"
						
					}
				}
			}
			//if cell is selected, change the background color of cellOne.selectedBackgroundView to darkGray or lightGray depending on light or dark mode
			let _: () = cellOne.selectedBackgroundView = {
				let view = UIView()
				view.layer.cornerRadius = 5
				if self.traitCollection.userInterfaceStyle == .dark {
					view.backgroundColor = UIColor.darkGray
				} else {
					view.backgroundColor = UIColor.lightGray
				}
				
				return view
			}()
			
			cellOne.selectedBackgroundView!.frame = CGRect(x: (cellOne.frame.width-cellOne.frame.height)/2, y: 0, width: cellOne.frame.height, height: cellOne.frame.height)
		}
		
		cellOne.label.text = numMonth[indexPath.item]
		
		return cellOne
	}
}

//MARK: ColectionViewDelegate
extension MonthVC: UICollectionViewDelegate {
	///enabling infinite scroll by calling the scroll() function.
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		if(collectionView.indexPathsForVisibleItems[0] == IndexPath.init(item: 0, section: 0)) {
			yearLabel.text = yearString(date: event!.startDate!)
			monthLabel.text = monthString(date: event!.startDate!)
			
		} else if collectionView.indexPathsForVisibleItems[0] == IndexPath.init(item: 49, section: 0){
			yearLabel.text = yearString(date: plusmonth(date: event!.startDate!))
			monthLabel.text = monthString(date: plusmonth(date: event!.startDate!))
		}
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if (!decelerate) {
			if(collectionView.indexPathsForVisibleItems[0] == IndexPath.init(item: 0, section: 0)) {
				yearLabel.text = yearString(date: event!.startDate!)
				monthLabel.text = monthString(date: event!.startDate!)
				
			} else if collectionView.indexPathsForVisibleItems[0] == IndexPath.init(item: 49, section: 0){
				yearLabel.text = yearString(date: plusmonth(date: event!.startDate!))
				monthLabel.text = monthString(date: plusmonth(date: event!.startDate!))
			}
		}
	}
	
	///Setting up how each cell in the month Calendar will look
	func setCollectionViewLayout() {
		let relativeWidth: CGFloat = 5
		let cellWidth = ((collectionView.frame.size.width-(relativeWidth*2))/7)
		let cellHeight = (collectionView.frame.size.height)/7
		
		let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
		flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		flowLayout.sectionInsetReference = .fromSafeArea
		flowLayout.sectionInset = UIEdgeInsets(top: 0, left: relativeWidth, bottom: 0, right: relativeWidth)
		flowLayout.minimumLineSpacing = 0
		flowLayout.minimumInteritemSpacing = 0
		
		collectionView.layer.cornerRadius = 5
		collectionView.isPagingEnabled = true
		
	}
	
	///Checks to see if the value contained in cellOne.label.text is an integer. If true it updates the previously selected cell and the newly selected cell so that theDotViewBackGrouldView of CollectionViewCell's background color is equal to the background of the cell. It does these things by calling cellForItemAt above
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
		
		if(Int(cellOne.label.text!) != nil) {
			selectCell(indexPath: indexPath)
			collectionView.reloadItems(at: [indexPath])
			return true
			
		} else {
			return false
			
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
		selectedDate = dateFromNumbers(date: "\(monthString(date: minusMonth(date: event!.startDate))) \(numMonth[indexPath.item]), \(yearString(date: event!.startDate))")
		collectionView.reloadItems(at: [indexPath])
		return true
	}
	
	///Logic for updating userSelectedDate after a new cell is selected by user. This method then reloads the tableView data if data exists, otherwise it informs the user that no events are scheduled for the newly selected date.
	func selectCell(indexPath: IndexPath) {
		if Int(numMonth[indexPath.item]) != nil {
			selectedDate = dateFromNumbers(date: "\(monthString(date: event!.startDate)) \(numMonth[indexPath.item]), \(yearString(date: event!.startDate))")
			
		}
	}
}
