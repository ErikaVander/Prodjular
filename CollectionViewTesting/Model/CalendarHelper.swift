//
//  TheData.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/10/21.
//

import Foundation

var num: [String] = []

let calendar = Calendar.current

func plusmonth(date: Date) -> Date
{
    return calendar.date(byAdding: .month, value: 1, to: date)!
}

func minusMonth(date: Date) -> Date
{
    return calendar.date(byAdding: .month, value: -1, to: date)!
}

func numDaysInMonth(date: Date) -> Int
{
    let range = calendar.range(of: .day, in: .month, for: date)!
    return range.count
}

func monthString(date: Date) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "LLLL"
    return dateFormatter.string(from: date)
}

func yearString(date: Date) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    return dateFormatter.string(from: date)
}

func dayOfMonth(date: Date) -> Int
{
    let components = calendar.dateComponents([.day], from: date)
    return components.day!
}

func weekDay(date: Date) ->  Int
{
	let theComponent = calendar.dateComponents([.weekday], from: date)
	return theComponent.weekday! - 1
}

func firstDayOfMonth(date: Date) -> Date
{
	if calendar.component(.day, from: date) != 1 {
		let firstDay: Date = calendar.nextDate(after: date, matching: DateComponents(day: 1), matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .backward)!
		return firstDay
	} else {
		return date
	}
}

func fillMonth(parDate: Date)
{
	num.removeAll()
	var x: Int = 0
	var startDate = minusMonth(date: parDate)
	while x < 3 {
		//print("x in loop: \(x)")
		let daysInMonth = numDaysInMonth(date: startDate)
		let firstDayMonth = firstDayOfMonth(date: startDate)
		let startingSpaces = weekDay(date: firstDayMonth)
		
		num.append("SU")
		num.append("MO")
		num.append("TU")
		num.append("WE")
		num.append("TH")
		num.append("FR")
		num.append("SA")
		
		var count: Int = 1
		
		while (count < 43)
		{
			if (count <= startingSpaces || count - startingSpaces > daysInMonth)
			{
				num.append("")
			}
			else
			{
				num.append(String(count - startingSpaces))
			}
			count += 1
		}
		x  += 1
		startDate = plusmonth(date: startDate)
	}
	
	print("done with fillMonth")
}
