//
//  ViewController.swift
//  CloudList
//
//  Created by Manisha Yeramareddy on 3/14/16.
//  Copyright © 2016 Manisha Yeramareddy. All rights reserved.
//

import UIKit
import CloudKit

class ListsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Fetch User Record ID
        fetchUserRecordID()
    }
    
    private func fetchUserRecordID() {
        // fetch a reference to the application's default container
        let defaultContainer = CKContainer.defaultContainer()
        
        // Fetch User Record
        // closure will be called on a background thread by default - so explicitly call on main thread
        defaultContainer.fetchUserRecordIDWithCompletionHandler { (recordID, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecordID = recordID {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.fetchUserRecord(userRecordID)
                })
            }
        }
    }
    
    private func fetchUserRecord(recordID: CKRecordID) {
        // fetch a reference to the application's default container
        let defaultContainer = CKContainer.defaultContainer()
        
        // Fetch users Private Database
        let privateDatabase = defaultContainer.privateCloudDatabase
        
        // Fetch User Record
        privateDatabase.fetchRecordWithID(recordID) { (record, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecord = record {
                print(userRecord)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

