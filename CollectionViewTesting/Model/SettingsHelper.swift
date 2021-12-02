//
//  SettingsHelper.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 11/30/21.
//

import Foundation

var currentUserSettings = SettingsHelper.init(autoBreakLength: 0.25, autoPrepLength: 1, addNewDirection: "up", autoWorkDays: ["Mon", "Tue", "Wed", "Thu", "Fri"])

struct SettingsHelper {
	var autoBreakLength: Float
	var autoPrepLength: Float
	var addNewDirection: String
	var autoWorkDays: [String]
}

