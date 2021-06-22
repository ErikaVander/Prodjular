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

//This was the original function used by youtuber but didn't understand how it really worked behind the scenes so I went with something else bellow.
//
//func firstOfMonth(date: Date) -> Date
//{
//    let component = calendar.dateComponents([.month, .year], from: date)
//    return calendar.date(from: component)!
//}

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
	let firstDay: Date = calendar.nextDate(after: date, matching: DateComponents(day: 1), matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .backward)!
    return firstDay
}
