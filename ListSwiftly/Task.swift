//
//  Task.swift
//  ListSwiftly
//
//  Created by Anthony Michael Fennell on 7/30/15.
//  Copyright (c) 2015 Ford Prefect. All rights reserved.
//

import Foundation
import CoreData

enum TaskColor: Int16 {
    case orange = 0
    case black, yellow, red, blue, purple, green
}

@objc(Task)
class Task: NSManagedObject {

    @NSManaged var timeStamp: NSDate
    @NSManaged var note: String
    @NSManaged var dueDate: NSDate
    @NSManaged var color: NSNumber
    @NSManaged var isFinished: NSNumber
    @NSManaged var taskID: String
}
