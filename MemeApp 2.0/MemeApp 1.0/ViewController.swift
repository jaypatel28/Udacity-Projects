//
//  ViewController.swift
//  MemeApp 1.0
//
//  Created by Jay Patel on 12/2/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    @IBOutlet weak var bottomMenuBar: UIToolbar!
    @IBOutlet weak var topMenuBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    

    var memeImage: UIImage!
    var didChooseImage: Bool = false
    var defaultTopText = "TOP"
    var defaultBottomText = "BOTTOM"
    
    let memeFontStyle = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0,
        
    ]
    
    let textFieldDelegate = TextFieldEditDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        shareButton.enabled = false
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        textFieldTop.defaultTextAttributes = memeFontStyle
        textFieldBottom.defaultTextAttributes = memeFontStyle
        textFieldBottom.textAlignment = NSTextAlignment.Center
        textFieldTop.textAlignment = NSTextAlignment.Center
        textFieldTop.delegate = textFieldDelegate
        textFieldBottom.delegate = textFieldDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func ShareMemedImage(sender: AnyObject) {
        if didChooseImage {
            if let shareImage = imagePickerView.image {
                memeImage = generateMemedImage()
                let shareController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
                
                shareController.completionWithItemsHandler = {activity, completed, returnedItems, error in
                    if completed {
                        self.saveMeme()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        // will need to remove in production
                        print("user cancelled UIActivity")
                    }
                    
                    }
                //presentViewController(shareController, animated: true, completion: nil)
                self.presentViewController(shareController, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imagePickerView.image = image
            didChooseImage = true
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        didChooseImage = false
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0.00
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    func saveMeme() {
        
        let meme = Meme(topText: textFieldTop.text!, bottomText: textFieldBottom.text!, originalImage: imagePickerView.image, memeImage: memeImage)
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        bottomMenuBar.hidden = true
        topMenuBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // TODO:  Show toolbar and navbar
        bottomMenuBar.hidden = false
        topMenuBar.hidden = false
        
        return memedImage
    }
    @IBAction func TestingMemeArray(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

