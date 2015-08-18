//
//  StatsViewController.swift
//  ListSwiftly
//
//  Created by Anthony Michael Fennell on 8/10/15.
//  Copyright (c) 2015 Ford Prefect. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var incompleteLabel: UILabel!
    @IBOutlet weak var onTimeLabel: UILabel!
    @IBOutlet weak var lateLabel: UILabel!
    
    
    @IBOutlet weak var onTimeChart: AFCircleChart!
    @IBOutlet weak var completionChart: AFCircleChart!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let stats = Model.sharedInstance.myStatKeeper()
        completedLabel.text = String(format: "%d", stats.tasksCompleted.intValue)
        incompleteLabel.text = String(format: "%d", stats.tasksIncomplete.intValue)
        onTimeLabel.text = String(format: "%d", stats.tasksCompletedOnTime.intValue)
        lateLabel.text = String(format: "%d", stats.tasksNotCompletedOnTime.intValue)
        
        onTimeChart.setLineWidth(16, atValue: Int(stats.tasksCompletedOnTime.intValue), totalValue: Int(stats.tasksCompletedOnTime.intValue + stats.tasksNotCompletedOnTime.intValue), chartColor: UIColor.orangeColor(), descriptionString: "On time %")
        
        completionChart.setLineWidth(16, atValue: Int(stats.tasksCompleted.intValue), totalValue: Int(stats.tasksCompleted.intValue + stats.tasksIncomplete.intValue), chartColor: UIColor.blueColor(), descriptionString: "Completion %")
        
        onTimeChart.animatePath()
        completionChart.animatePath()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
