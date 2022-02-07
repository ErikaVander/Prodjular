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
	@IBOutlet weak var EndDatePicker: UIDatePicker!
	@IBOutlet weak var StartDatePicker: UIDatePicker!
	@IBOutlet weak var ColorPickerCollectionView: UICollectionView!
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet var descriptionToolbar: UIToolbar!
	
	@IBAction func doneEditing(_ sender: UIBarButtonItem) {
		descriptionTextView.resignFirstResponder()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		descriptionTextView.layer.cornerRadius = 5
		descriptionTextView.backgroundColor = .secondarySystemBackground
		descriptionTextView.textColor = .placeholderText
		descriptionTextView.text = "Description"
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		NameOfEvent.becomeFirstResponder()
		
		ColorPickerCollectionView.register(UINib(nibName: "ColorPickerCell", bundle: nil), forCellWithReuseIdentifier: "ColorPickerReusableCell")
		
		ColorPickerCollectionView.delegate = self
		ColorPickerCollectionView.dataSource = self
		
		descriptionTextView.delegate = self
		descriptionTextView.returnKeyType = .default
		
		descriptionToolbar.frame.size.height = 30
		descriptionTextView.inputAccessoryView = descriptionToolbar
	}

	///The event that occurs after the user creates an event. The new event is made into a Prodular Event and added to the database using the function newEvent defined in the file DatabaseManager.swift.
	@IBAction func saveEvent(_ sender: Any) {
		let month = calendar.component(.month, from: selectedDate)
		let day = calendar.component(.day, from: selectedDate)
		let year = calendar.component(.year, from: selectedDate)
		
		let startHour = calendar.component(.hour, from: StartDatePicker.date)
		let startMinute = calendar.component(.minute, from: StartDatePicker.date)
		
		let endHour = calendar.component(.hour, from: EndDatePicker.date)
		let endMinute = calendar.component(.minute, from: EndDatePicker.date)
		//let second = calendar.component(.second, from: DatePicker.date)
		
		let startDateComponent = DateComponents( year: year, month: month, day: day, hour: startHour, minute: startMinute, second: 0)
		let endDateComponent = DateComponents( year: year, month: month, day: day, hour: endHour, minute: endMinute, second: 0)
		
		let startDate = calendar.date(from: startDateComponent)
		let endDate = calendar.date(from: endDateComponent)
		
		let dateFormat = DateFormatter()
		dateFormat.timeStyle = .full
		dateFormat.dateStyle = .short
		
		DatabaseManager.shared.newEvent(with: ProjdularEvent(id: "NotYetFound", nameOfEvent: NameOfEvent.text!, startDate: startDate, endDate: endDate, tagName: "optional", tagColor: selectedColorFromColorsArray.name, description: descriptionTextView.text))
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

extension EventViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		descriptionTextView.text = ""
	}
	
	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		if descriptionTextView.text == "" {
			descriptionTextView.textColor = .placeholderText
			descriptionTextView.text = "Description"
		}
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextView) -> Bool {
		if textField == descriptionTextView {
			descriptionTextView.resignFirstResponder()
		}
		return true
	}
}
