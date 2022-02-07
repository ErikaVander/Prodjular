//
//  CalendarViewController_Database.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 1/12/22.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseCore

//MARK: FirebaseRealtimeDatabase
extension CalendarViewController {
	///Getting all the events created by the user and storing them in eventList so that the table view can display them.
	func observeEvents() {
		let eventRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("events")
		
		eventRef.observe(.value, with: { snapshot in
			
			var tempEvents = [ProjdularEvent]()
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let startDate = dict["startDate"] as? String,
				   let endDate = dict["endDate"] as? String,
				   let nameOfEvent = dict["name"] as? String,
				   let tagName = dict["tagName"] as? String,
				   let tagColor = dict["tagColor"] as? String,
				   let description = dict["description"] as? String
				{
				//let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
				
				let event = ProjdularEvent(id: id, nameOfEvent: nameOfEvent, startDate: dateFormatter.date(from: startDate), endDate: dateFormatter.date(from: endDate), tagName: tagName, tagColor: tagColor, description: description)
				
				tempEvents.append(event)
				}
			}
			eventList = tempEvents
			//print("--eventsForDate: \(eventsForDate(parDate: selectedDate)) selectedDate: \(selectedDate))")
			if(initialLoadingOfData == true) {
				self.tableView.reloadData()
				initialLoadingOfData = false
			}
			
			self.collectionView.reloadData()
			
			let dateToSelectPlusSeven = 7+weekDay(date: firstDayOfMonth(date: selectedDate))+dayOfMonth(date: selectedDate)
			
			self.collectionView.selectItem(at: IndexPath(item: (49+dateToSelectPlusSeven-1), section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.init(rawValue: UInt(dateToSelectPlusSeven)))
			
			previouslySelectedCellIndexPath = self.collectionView.indexPathsForSelectedItems?.first
		})
		
	}
	///Get all colors made by the user and stored on firebase by the current user.
	func observeColors() {
		let eventRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("colors")
		
		eventRef.observe(.value, with: { snapshot in
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let dict = childSnapshot.value as? [String: Any],
				   let name = dict["name"] as? String,
				   let redValue = dict["redValue"] as? Float,
				   let blueValue = dict["blueValue"] as? Float,
				   let greenValue = dict["greenValue"] as? Float
				{
				ColorsArray.append(Colors(name: name, redValue: redValue, blueValue: blueValue, greenValue: greenValue))
				}
			}
		})
	}
	func observeUserSettings() {
		let settingsRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("userSettings")
		
		settingsRef.observe(.value, with: { snapshot in
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let dict = childSnapshot.value as? [String: Any],
				   let autoBreakLength = dict["autoBreakLength"] as? Float,
				   let autoPrepLength = dict["autoPrepLength"] as? Float,
				   let addNewDirection = dict["addNewDirection"] as? String,
				   let autoWorkDays = dict["autoWorkDays"] as? [String]
				{
				currentUserSettings = SettingsHelper.init(autoBreakLength: autoBreakLength, autoPrepLength: autoPrepLength, addNewDirection: addNewDirection, autoWorkDays: autoWorkDays)
				}
			}
		})
	}
}


