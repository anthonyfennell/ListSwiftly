//
//  StatKeeper.swift
//  ListSwiftly
//
//  Created by Anthony Michael Fennell on 8/10/15.
//  Copyright (c) 2015 Ford Prefect. All rights reserved.
//

import Foundation
import CoreData

@objc(StatKeeper)
class StatKeeper: NSManagedObject {

    @NSManaged var tasksCompletedOnTime: NSNumber
    @NSManaged var tasksNotCompletedOnTime: NSNumber
    @NSManaged var tasksCompleted: NSNumber
    @NSManaged var tasksIncomplete: NSNumber

}
