//
//  Color.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 11/12/21.
//

import Foundation
import UIKit

var selectedColorFromColorsArray: Colors = ColorsArray [0]

var ColorsArray = [
	Colors(name: "MyWhite", redValue: 0.180, blueValue: 0.180, greenValue: 0.180),
	Colors(name: "MyBlue", redValue: 0.5, blueValue: 0.78, greenValue: 0.885),
	Colors(name: "MyBrown", redValue: 0.678, blueValue: 0.5, greenValue: 0.0),
	Colors(name: "MyGreen", redValue: 0.516, blueValue: 0.807, greenValue: 0.526),
	Colors(name: "MyOrange", redValue: 0.887, blueValue: 0.822, greenValue: 0.560),
	Colors(name: "MyPurple", redValue: 0.790, blueValue: 0.335, greenValue: 1.0),
	Colors(name: "MyRed", redValue: 0.836, blueValue: 0.350, greenValue: 0.319)
]

struct Colors {
	var name: String
	var redValue: Float?
	var blueValue: Float?
	var greenValue: Float?
}
