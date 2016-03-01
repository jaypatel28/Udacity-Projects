//
//  TextFieldEdit.swift
//  MemeApp 1.0
//
//  Created by Jay Patel on 12/2/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import Foundation
import UIKit

class TextFieldEditDelegate: NSObject, UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        textField.textAlignment = .Center
        let text = String(newText)
            textField.text = text
        
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        if textField.text == "" {
//            textField.text = "TOP"
//        }
//        
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}