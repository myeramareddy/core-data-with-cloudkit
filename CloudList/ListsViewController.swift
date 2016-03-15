//
//  ViewController.swift
//  CloudList
//
//  Created by Manisha Yeramareddy on 3/14/16.
//  Copyright © 2016 Manisha Yeramareddy. All rights reserved.
//

import UIKit
import CloudKit
import SVProgressHUD

class ListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddListViewControllerDelegate {
    
    static let ListCell = "myCell"
    let RecordTypeLists = "Lists"
    let SegueListDetail = "ListDetail"
    
    var lists = [CKRecord]()
    var selection: Int?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupView()
        fetchLists()
    }
    
    private func setupView() {
        tableView.hidden = true
        messageLabel.hidden = true
        activityIndicator.startAnimating()
    }
    
    private func fetchLists() {
        // Fetch Private Database
        let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
        
        // Initialize Query
        let query = CKQuery(recordType: RecordTypeLists, predicate: NSPredicate(format: "TRUEPREDICATE"))
        
        // Configure Query
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Perform Query
        privateDatabase.performQuery(query, inZoneWithID: nil) { (records, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Process Response on Main Thread
                self.processResponseForQuery(records, error: error)
            })
        }
    }
    
    private func processResponseForQuery(records: [CKRecord]?, error: NSError?) {
        var message = ""
        
        if let error = error {
            print(error)
            message = "Error Fetching Records"
            
        } else if let records = records {
            lists = records
            if lists.count == 0 {
                message = "No Records Found"
            }
            
        } else {
            message = "No Records Found"
        }
        
        if message.isEmpty {
            tableView.reloadData()
        } else {
            messageLabel.text = message
        }
        
        updateView()
    }
    
    private func updateView() {
        let hasRecords = lists.count > 0
        
        tableView.hidden = !hasRecords
        messageLabel.hidden = hasRecords
        activityIndicator.stopAnimating()
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
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        let cell = tableView.dequeueReusableCellWithIdentifier(ListsViewController.ListCell, forIndexPath: indexPath)
        
        // Configure Cell
        cell.accessoryType = .DetailDisclosureButton
        
        // Fetch Record
        let list = lists[indexPath.row]
        if let listName = list.objectForKey("name") as? String {
            // Configure Cell
            cell.textLabel?.text = listName
            
        } else {
            cell.textLabel?.text = "-"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Save Selection
        selection = indexPath.row
        
        // Perform Segue
        performSegueWithIdentifier(SegueListDetail, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            case SegueListDetail:
            // Fetch Destination View Controller
            let addListViewController = segue.destinationViewController as! AddListViewController
            
            // Configure View Controller
            addListViewController.delegate = self
            
            if let selection = selection {
                // Fetch List
                let list = lists[selection]
                
                // Configure View Controller
                addListViewController.list = list
            }
        default:
            break
        }
    }
    
    func controller(controller: AddListViewController, didAddList list: CKRecord) {
        // Add List to Lists
        lists.append(list)
        
        // Sort Lists
        sortLists()
        print("LIST: \(lists)")
        
        // Update Table View
        tableView.reloadData()
        
        // Update View
        updateView()
    }
    
    func controller(controller: AddListViewController, didUpdateList list: CKRecord) {
        // Sort Lists
        sortLists()
        
        // Update Table View
        tableView.reloadData()
    }
    
    private func sortLists() {
        lists.sortInPlace {
            var result = false
            let name0 = $0.objectForKey("name") as? String
            let name1 = $1.objectForKey("name") as? String
            
            if let listName0 = name0, listName1 = name1 {
                result = listName0.localizedCaseInsensitiveCompare(listName1) == .OrderedAscending
            }
            
            return result
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

