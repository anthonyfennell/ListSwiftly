//
//  Utils.swift
//  ListSwiftly
//
//  Created by Anthony Michael Fennell on 8/11/15.
//  Copyright © 2015 Ford Prefect. All rights reserved.
//

import Foundation

extension NSDate {
    
    func incrementByDays(days: Int) -> NSDate {
        
        let date = NSDate(timeInterval: Double(days * 24 * 3600), sinceDate: self)
        return date
    }
}