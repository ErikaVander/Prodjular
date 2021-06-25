//
//  Event.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 6/16/21.
//

import UIKit

var eventList = [Event]()

class Event {
	var id: Int!
	var name: String!
	var date: Date!
}

func eventsForDate(parDate: Date) -> [Event] {
	var daysEvents = [Event]()
	for event in eventList
	{
		let eventDate = calendar.dateComponents([.day, .month, .year], from: event.date)
		let parDateC = calendar.dateComponents([.day, .month, .year], from: parDate)
		if(eventDate == parDateC)
		{
			daysEvents.append(event)
			print("addedEvent")
		}
	}
	return daysEvents
}
