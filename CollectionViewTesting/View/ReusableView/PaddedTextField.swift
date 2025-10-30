//
//  PaddedTextField.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 10/20/25.
//


import UIKit

class PaddedTextField: UITextField {

    var textPadding = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0) // Adjust these values as needed

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.placeholderRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
