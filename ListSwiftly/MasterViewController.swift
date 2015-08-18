//
//  MasterViewController.swift
//  ListSwiftly
//
//  Created by Anthony Michael Fennell on 7/30/15.
//  Copyright (c) 2015 Ford Prefect. All rights reserved.
//

import UIKit
import CoreData


class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    enum segueID: String {
        case detailView     = "showDetail"
        case statsView      = "showStats"
    }

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var isAddingNewTask = false
    var taskToPass: Task? = nil


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        let statsButton = UIBarButtonItem(title: "Stats", style: UIBarButtonItemStyle.Plain, target: self, action: "stats:")
        self.navigationItem.rightBarButtonItems = [addButton, statsButton]
        
        let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TaskCell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        isAddingNewTask = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        taskToPass = Model.sharedInstance.createTask("", dueDate: NSDate())
        isAddingNewTask = true
        performSegueWithIdentifier(segueID.detailView.rawValue, sender: self)
    }

    func stats(sender: AnyObject) {
        performSegueWithIdentifier(segueID.statsView.rawValue, sender: self)
    }
    
    
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueID.detailView.rawValue {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destinationViewController as! DetailViewController
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task
                object.isFinished = false
                controller.aTask = object
            } else {
                let controller = segue.destinationViewController as! DetailViewController
                controller.aTask = taskToPass
            }
        }
    }

    
    
    
    
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            Model.sharedInstance.removeTask(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(segueID.detailView.rawValue, sender: self)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        var editActions = [UITableViewRowAction]()
        let rawString = self.fetchedResultsController.sections![indexPath.section].name

        if rawString == "0" {
            /* Tasks section */
            
            let finishedRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Finish", handler: {action, indexpath in
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task
                object.isFinished = NSNumber(bool: true)
                Model.sharedInstance.removeLocalNotification(object)
                
                let date = NSDate()
                if object.dueDate.compare(date) == NSComparisonResult.OrderedSame {
                    Model.sharedInstance.completedTaskOnTime(true)
                } else if object.dueDate.compare(date) == NSComparisonResult.OrderedDescending {
                    Model.sharedInstance.completedTaskOnTime(true)
                } else {
                    Model.sharedInstance.completedTaskOnTime(false)
                }
                Model.sharedInstance.save()
            });
            finishedRowAction.backgroundColor = UIColor.lightGrayColor()
        
            let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
                Model.sharedInstance.removeLocalNotification(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task)
                Model.sharedInstance.removeTask(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task)
            });
            editActions.append(finishedRowAction)
            editActions.append(deleteRowAction)
        } else {
            /* Completed tasks section */
            
            let beginRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Begin", handler: {action, indexpath in
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task
                object.isFinished = NSNumber(bool: false)
                Model.sharedInstance.incrementStatKeeperTasks(true)
                Model.sharedInstance.scheduleLocalNotificationWithTask(object.note, fireDate: object.dueDate, aTask: object)
                Model.sharedInstance.save()
                self.taskToPass = object
                self.performSegueWithIdentifier(segueID.detailView.rawValue, sender: self)
            });
            beginRowAction.backgroundColor = UIColor.lightGrayColor()
            
            let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
                Model.sharedInstance.removeTask(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task)
            });
            editActions.append(beginRowAction)
            editActions.append(deleteRowAction)
        }
        
        return editActions;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let rawString = self.fetchedResultsController.sections![section].name
        
        if rawString == "0" {
            return "Tasks"
        }
        return "Finished Tasks"
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd | hh:mm a"
        
        let taskCell = cell as! TaskTableViewCell
        taskCell.noteLabel.text = object.note
        taskCell.dateLabel.text = dateFormatter.stringFromDate(object.dueDate)
        let color = Model.sharedInstance.colorForTask(object.color.shortValue)
        taskCell.colorView.backgroundColor = color
        taskCell.colorView.layer.cornerRadius = 3.0
    }

    
    
    
    
    
    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Task", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let firstSort = NSSortDescriptor(key: "isFinished.boolValue", ascending: true)
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let sortDescriptors = [firstSort, sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "isFinished", cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	do {
            try _fetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
    	     // Replace this implementation with code to handle the error appropriately.
    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //println("Unresolved error \(error), \(error.userInfo)")
    	     abort()
    	}
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }
    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        
//    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

