//
//  AddListViewController.swift
//  CloudList
//
//  Created by Manisha Yeramareddy on 3/14/16.
//  Copyright © 2016 Manisha Yeramareddy. All rights reserved.
//

import UIKit
import CloudKit
import SVProgressHUD

protocol AddListViewControllerDelegate {
    func controller(controller: AddListViewController, didAddList list: CKRecord)
    func controller(controller: AddListViewController, didUpdateList list: CKRecord)
}

class AddListViewController: UIViewController {
    
    let RecordTypeLists = "Lists"
    
    var delegate: AddListViewControllerDelegate?
    var newList: Bool = true
    
    var list: CKRecord?
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // Update Helper
        newList = list == nil
        
        // Add Observer
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "textFieldTextDidChange:", name: UITextFieldTextDidChangeNotification, object: nameTextField)
    }
    
    override func viewDidAppear(animated: Bool) {
        nameTextField.becomeFirstResponder()
    }
    
    private func setupView() {
        updateNameTextField()
        updateSaveButton()
    }
    
    // MARK: -
    private func updateNameTextField() {
        if let name = list?.objectForKey("name") as? String {
            nameTextField.text = name
        }
    }
    
    // MARK: -
    private func updateSaveButton() {
        let text = nameTextField.text
        
        if let name = text {
            saveButton.enabled = !name.isEmpty
        } else {
            saveButton.enabled = false
        }
    }
    
    
    @IBAction func save(sender: AnyObject) {
        // Helpers
        let name = nameTextField.text
        
        // Fetch Private Database
        let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
        
        if list == nil {
            list = CKRecord(recordType: RecordTypeLists)
        }
        
        // Configure Record
        list?.setObject(name, forKey: "name")
        
        // Show Progress HUD
        SVProgressHUD.show()
        
        // Save Record
        privateDatabase.saveRecord(list!) { (record, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Dismiss Progress HUD
                SVProgressHUD.dismiss()
                
                // Process Response
                self.processResponse(record, error: error)
            })
        }
    }

    private func processResponse(record: CKRecord?, error: NSError?) {
        var message = ""
        
        if let error = error {
            print(error)
            message = "We were not able to save your list."
            
        } else if record == nil {
            message = "We were not able to save your list."
        }
        
        if !message.isEmpty {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
            
            // Present Alert Controller
            presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            // Notify Delegate
            if newList {
                delegate?.controller(self, didAddList: list!)
            } else {
                delegate?.controller(self, didUpdateList: list!)
            }
            
            // Pop View Controller
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldTextDidChange(notification: NSNotification) {
        updateSaveButton()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
