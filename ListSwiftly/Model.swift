//
//  Model.swift
//  ListSwiftly
//
//  Created by Anthony Michael Fennell on 7/30/15.
//  Copyright (c) 2015 Ford Prefect. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Model {
    static let sharedInstance = Model()
    let statsKeeperConstant = "STATS_KEEPER_CREATED"
    let context: NSManagedObjectContext
    let model: NSManagedObjectModel
    
    
    init() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        model = appDelegate.managedObjectModel
        context = appDelegate.managedObjectContext
        
        let notifTypes: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
        let settings = UIUserNotificationSettings(forTypes: notifTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
   
    
    
    /////////////////////////
    // MARK : Task methods
    /////////////////////////
    
    func allTasks(dateAscending: Bool) -> Array<Task> {
        
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Task", inManagedObjectContext: context)
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: dateAscending)
        request.sortDescriptors = [sortDescriptor]
        
        var result = [Task]()
        do {
            try result = (context.executeFetchRequest(request) as? [Task])!
        } catch {
            print("Fatal error \(error)")
        }
        
        return result
    }
    
    func createTask(note: String, dueDate: NSDate) -> Task {
        let newTask: Task = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: context) as! Task
        newTask.note = note
        newTask.timeStamp = NSDate()
        newTask.dueDate = dueDate
        newTask.color = NSNumber(short: 0)
        newTask.isFinished = NSNumber(bool: false)
        newTask.taskID = NSUUID().UUIDString
        self.incrementStatKeeperTasks(true)
        return newTask
    }
    
    func removeTask(theTask: Task) {
        if !theTask.isFinished.boolValue {
            self.incrementStatKeeperTasks(false)
        }
        
        context.deleteObject(theTask)
        do {
            try context.save()
        } catch {
            fatalError("Fatal error \(error)")
        }
    }
    
    func save() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveContext()
    }
    
    
    
    
    
    //////////////////////
    // MARK : Stat Keeper
    //////////////////////
    
    func myStatKeeper() -> StatKeeper {
        var stats: StatKeeper!
        
        let targetDefaults = NSUserDefaults.standardUserDefaults()
        if !targetDefaults.boolForKey(statsKeeperConstant) {
            targetDefaults.setBool(true, forKey: statsKeeperConstant)
            targetDefaults.synchronize()
            stats = NSEntityDescription.insertNewObjectForEntityForName("StatKeeper", inManagedObjectContext: context) as! StatKeeper
            stats.tasksCompleted = 0
            stats.tasksCompletedOnTime = 0
            stats.tasksIncomplete = 0
            stats.tasksNotCompletedOnTime = 0
            self.save()
        } else {
            let request = NSFetchRequest()
            request.entity = NSEntityDescription.entityForName("StatKeeper", inManagedObjectContext: context)
            
            var result = [StatKeeper]()
            do {
                try result = context.executeFetchRequest(request) as! [StatKeeper]
            } catch {
                print("Fatal error finding StatKeeper \(error)")
            }
            stats = result[0]
        }
        
        return stats
    }
    
    func completedTaskOnTime(isOnTime: Bool) {
        let stats = self.myStatKeeper()
        var completed = stats.tasksCompleted.intValue
        var onTime = stats.tasksCompletedOnTime.intValue
        var incomplete = stats.tasksIncomplete.intValue
        var notOnTime = stats.tasksNotCompletedOnTime.intValue
        
        
        if isOnTime {
            completed++
            onTime++
            incomplete--
        } else {
            completed++
            notOnTime++
            incomplete--
        }
        
        stats.tasksCompleted = NSNumber(int: completed)
        stats.tasksCompletedOnTime = NSNumber(int: onTime)
        stats.tasksIncomplete = NSNumber(int: incomplete)
        stats.tasksNotCompletedOnTime = NSNumber(int: notOnTime)
        self.save()
    }
    
    func incrementStatKeeperTasks(shouldIncrement: Bool) {
        let stats = self.myStatKeeper()
        var incomplete = stats.tasksIncomplete.intValue
        
        if shouldIncrement {
            incomplete++
        } else {
            incomplete--
        }
        stats.tasksIncomplete = NSNumber(int: incomplete)
        self.save()
    }
    
    
    
    
    
    
    //////////////////////////////
    // MARK : Local Notifications
    //////////////////////////////
    
    func scheduleLocalNotificationWithTask(title: String, fireDate: NSDate, aTask: Task) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = fireDate
        localNotification.alertBody = title
        localNotification.alertAction = "Task due soon"
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.userInfo = ["uid": aTask.taskID]
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func rescheduleLocalNotificationWithTask(newTitle: String, newFireDate: NSDate, aTask: Task) {
        removeLocalNotification(aTask)
        scheduleLocalNotificationWithTask(newTitle, fireDate: newFireDate, aTask: aTask)
    }
    
    func removeLocalNotification(theTask: Task) {
        let eventsArray = UIApplication.sharedApplication().scheduledLocalNotifications
        
        if let events = eventsArray {
        
        for var i = 0; i < events.count; i++ {
            let note: UILocalNotification = events[i] as UILocalNotification
            
            if let userInfoCurrent = note.userInfo {
                if let uid = userInfoCurrent["uid"] as? NSString {
                    if uid.isEqualToString(theTask.taskID) {
                        UIApplication.sharedApplication().cancelLocalNotification(note)
                    }
                }
            }
        }
        }
    }
    
    
    
    
    // MARK : Helper methods
    
    func colorForTask(value: Int16) -> UIColor {
        
        let taskEnum: TaskColor = TaskColor(rawValue: value)!
        
        switch taskEnum {
        case TaskColor.orange:
            return UIColor.orangeColor()
        case TaskColor.black:
            return UIColor.blackColor()
        case TaskColor.blue:
            return UIColor.blueColor()
        case TaskColor.purple:
            return UIColor.purpleColor()
        case TaskColor.red:
            return UIColor.redColor()
        case TaskColor.yellow:
            return UIColor.yellowColor()
        case TaskColor.green:
            return UIColor.greenColor()
        default:
            return UIColor.orangeColor()
        }
    }
}
