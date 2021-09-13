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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		NameOfEvent.becomeFirstResponder()
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
		
		print("--component: \(component)")
		
		print("--component.date: \(String(describing: theNewDate))")
		
		let dateFormat = DateFormatter()
		dateFormat.timeStyle = .full
		dateFormat.dateStyle = .short
		
		print("--string of date: \(dateFormat.string(from: theNewDate!))")
		
		DatabaseManager.shared.newEvent(with: ProjdularEvent(id: "NotYetFound", nameOfEvent: NameOfEvent.text!, userID: Auth.auth().currentUser!.uid, date: theNewDate, tagName: "optional", tagColor: "red"))
	}
}
