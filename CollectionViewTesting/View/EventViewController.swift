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
		DatabaseManager.shared.newEvent(with: ProjdularEvent(nameOfEvent: NameOfEvent.text!, userID: Auth.auth().currentUser!.uid, date: DatePicker!.date, tag: "optional"))
	}
}
