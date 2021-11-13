//
//  EventViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 6/16/21.
//

import UIKit
import FirebaseAuth

class EventViewController: UIViewController
{
	
	@IBOutlet weak var NameOfEvent: UITextField!
	@IBOutlet weak var DatePicker: UIDatePicker!
	@IBOutlet weak var ColorPickerCollectionView: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		NameOfEvent.becomeFirstResponder()
		
		ColorPickerCollectionView.register(UINib(nibName: "ColorPickerCell", bundle: nil), forCellWithReuseIdentifier: "ColorPickerReusableCell")
		
		ColorPickerCollectionView.delegate = self
		ColorPickerCollectionView.dataSource = self
	}

	///The event that occurs after the user creates an event. The new event is made into a Prodular Event and added to the database using the function newEvent defined in the file DatabaseManager.swift.
	@IBAction func saveEvent(_ sender: Any) {
		let month = calendar.component(.month, from: selectedDate)
		let day = calendar.component(.day, from: selectedDate)
		let year = calendar.component(.year, from: selectedDate)
		
		let hour = calendar.component(.hour, from: DatePicker.date)
		let minute = calendar.component(.minute, from: DatePicker.date)
		//let second = calendar.component(.second, from: DatePicker.date)
		
		let component = DateComponents( year: year, month: month, day: day, hour: hour, minute: minute, second: 0)
		
		let theNewDate = calendar.date(from: component)
		
		let dateFormat = DateFormatter()
		dateFormat.timeStyle = .full
		dateFormat.dateStyle = .short
		
		DatabaseManager.shared.newEvent(with: ProjdularEvent(id: "NotYetFound", nameOfEvent: NameOfEvent.text!, date: theNewDate, tagName: "optional", tagColor: selectedColorFromColorsArray.name))
		selectedColorFromColorsArray = ColorsArray[0]
	}
	@IBAction func selectDefaultColor(_ sender: UIButton) {
		selectedColorFromColorsArray = ColorsArray[0]
		ColorPickerCollectionView.deselectItem(at: ColorPickerCollectionView.indexPathsForSelectedItems![0], animated: true)
	}
}

//MARK: ColorPickerCollectionViewDelegate
extension EventViewController: UICollectionViewDelegate {
	
}

//MARK: ColorPickerCollectionViewDataSource
extension EventViewController: UICollectionViewDataSource {
	///Returns the number of items in one section of the collectionView. For some reason, it won't display 6 items unless I return 7.
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 7
	}
	
	///Sets up each cell in ColorPickerCollectionView
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = ColorPickerCollectionView.dequeueReusableCell(withReuseIdentifier: "ColorPickerReusableCell", for: indexPath) as! ColorPickerCell
		
		cell.ColorContainerView.backgroundColor = UIColor(named: ColorsArray[indexPath.item+1].name)
		cell.ColorContainerView.layer.cornerRadius = cell.ColorContainerView.frame.height/5
		
		cell.automaticallyUpdatesBackgroundConfiguration = true
		ColorPickerCollectionView.allowsMultipleSelection = false
		
		let _: () = cell.selectedBackgroundView = {
			let view = UIView()
			view.layer.cornerRadius = 5
			view.backgroundColor = .white
			
			return view
		}()
		
		return cell
	}
	
	///Triggered when a cell is selected.
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		//let cell = ColorPickerCollectionView.dequeueReusableCell(withReuseIdentifier: "ColorPickerReusableCell", for: indexPath) as! ColorPickerCell
		selectedColorFromColorsArray = ColorsArray[indexPath.item+1]
	}
	
}
