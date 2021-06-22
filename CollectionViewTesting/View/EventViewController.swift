//
//  EventViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 6/16/21.
//

import UIKit

class EventViewController: UIViewController
{
	
	@IBOutlet weak var NameOfEvent: UITextField!
	@IBOutlet weak var DatePicker: UIDatePicker!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		NameOfEvent.becomeFirstResponder()
	}

	@IBAction func saveEvent(_ sender: Any) {
		save()
	}
	func save() {
		let newEvent = Event()
		newEvent.id = eventList.count
		newEvent.name = NameOfEvent.text
		newEvent.date = DatePicker.date
		
		eventList.append(newEvent)
	}
}
