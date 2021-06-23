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
		if(event.date == parDate)
		{
			daysEvents.append(event)
		}
	}
	return daysEvents
}
