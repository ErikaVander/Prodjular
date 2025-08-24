//
//  Event.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 6/16/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol eventServiceDelegate {
	func logicForDeletingTableViewCell(_ databaseManager: eventService, indexPath: IndexPath)
}

///An array of ProjdularEvents
var eventList = [ProjdularEvent]()

///The definition of a ProdjularEvent.
struct ProjdularEvent : Equatable {
	var id: String
	let nameOfEvent: String
	var startDate: Date!
	var endDate: Date!
	var tagName: String?
	var tagColor: String?
	var description: String?
}

final class eventService {
	static let shared = eventService()
	
	var delegate: eventServiceDelegate?
	
	private let database = Database.database().reference()
	
	///Returns a list of all events on a given date
	public func eventsForDate(parDate: Date) -> [ProjdularEvent] {
		var daysEvents = [ProjdularEvent]()
		for event in eventList {
			let eventDate = calendar.dateComponents([.day, .month, .year], from: event.startDate)
			let parDateC = calendar.dateComponents([.day, .month, .year], from: parDate)
			if(eventDate == parDateC) {
				daysEvents.append(event)
				//print("--addedEvent")
			}
		}
		return daysEvents
	}
	
	///Writes the new event into the firebase database.
	public func newEvent(with event: ProjdularEvent) {
		let dateformat = DateFormatter()
		dateformat.dateStyle = .long
		dateformat.timeStyle = .long
		database.child("users").child(Auth.auth().currentUser!.uid).child("events").childByAutoId().setValue([
			"name": event.nameOfEvent,
			"startDate": dateformat.string(from: event.startDate),
			"endDate": dateformat.string(from: event.endDate),
			"tagName": event.tagName,
			"tagColor": event.tagColor,
			"description": event.description
		])
		selectedDate = event.startDate
		eventList.append(event)
	}
	
	///Deletes event
	public func deleteEvent(with event: ProjdularEvent, indexPath: IndexPath) {
		/*self.database.ref.child("users/\(Auth.auth().currentUser!.uid)/events/\(String(describing: event.id))").removeValue() {_,_ in
		 print("--LogicForDeletingTableViewCell about to be called")
		 self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
		 print("--at the end")
		 }*/
		database.child("users").child(Auth.auth().currentUser!.uid).child("events").child(String(describing: event.id)).setValue(nil) {
			(error: Error?, ref: DatabaseReference) in
			if let error = error {
				print("**Data could not be saved: \(error).")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("**Data saved successfully!")
			}
			
		}
	}
}
