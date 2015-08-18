//
//  DetailViewController.swift
//  ListSwiftly
//
//  Created by Anthony Michael Fennell on 7/30/15.
//  Copyright (c) 2015 Ford Prefect. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    
    weak var selectedButton: UIButton?
    var aTask: Task!
    var lastColor = TaskColor.orange
    
    
    func configureView() {
        // Update the user interface for the detail item.

        noteField.text = aTask.note
        datePicker.date = aTask.dueDate
        datePicker.minimumDate = NSDate()
        
        if let colorNum = aTask?.color {
            let button: UIButton?
            
            switch colorNum.shortValue {
            case TaskColor.orange.rawValue: // default value for new task
                button = orangeButton
            case TaskColor.black.rawValue:
                button = blackButton
            case TaskColor.yellow.rawValue:
                button = yellowButton
            case TaskColor.red.rawValue:
                button = redButton
            case TaskColor.blue.rawValue:
                button = blueButton
            case TaskColor.purple.rawValue:
                button = purpleButton
            case TaskColor.green.rawValue:
                button = greenButton
            default:
                button = orangeButton
            }
            
            button?.layer.borderWidth = 7
            selectedButton = button
        }

        redButton.layer.cornerRadius = 5
        redButton.layer.borderColor = UIColor.whiteColor().CGColor
        orangeButton.layer.cornerRadius = 5
        orangeButton.layer.borderColor = UIColor.whiteColor().CGColor
        purpleButton.layer.cornerRadius = 5
        purpleButton.layer.borderColor = UIColor.whiteColor().CGColor
        blueButton.layer.cornerRadius = 5
        blueButton.layer.borderColor = UIColor.whiteColor().CGColor
        blackButton.layer.cornerRadius = 5
        blackButton.layer.borderColor = UIColor.whiteColor().CGColor
        yellowButton.layer.cornerRadius = 5
        yellowButton.layer.borderColor = UIColor.whiteColor().CGColor
        greenButton.layer.cornerRadius = 5
        greenButton.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !aTask.note.isEmpty {
            Model.sharedInstance.rescheduleLocalNotificationWithTask(noteField.text!, newFireDate: datePicker.date, aTask: aTask)
        } else {
            Model.sharedInstance.scheduleLocalNotificationWithTask(noteField.text!, fireDate: datePicker.date, aTask: aTask)
        }
        
        aTask.note = noteField.text!
        aTask.dueDate = datePicker.date
        Model.sharedInstance.save()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK : Button change
    
    @IBAction func colorButtonTapped(sender: UIButton) {
        // Remove border from previously selected button
        selectedButton?.layer.borderWidth = 0.0
        
        switch sender {
        case orangeButton:
            aTask.color = NSNumber(short: TaskColor.orange.rawValue)
            selectedButton = orangeButton
        case blackButton:
            aTask.color = NSNumber(short: TaskColor.black.rawValue)
            selectedButton = blackButton
        case yellowButton:
            aTask.color = NSNumber(short: TaskColor.yellow.rawValue)
            selectedButton = yellowButton
        case redButton:
            aTask.color = NSNumber(short: TaskColor.red.rawValue)
            selectedButton = redButton
        case blueButton:
            aTask.color = NSNumber(short: TaskColor.blue.rawValue)
            selectedButton = blueButton
        case purpleButton:
            aTask.color = NSNumber(short: TaskColor.purple.rawValue)
            selectedButton = purpleButton
        case greenButton:
            aTask.color = NSNumber(short: TaskColor.green.rawValue)
            selectedButton = greenButton
        default:
            print("Somethings wrong, a button not registered has been pressed", appendNewline: false)
        }
        
        // Add border to newly selected button
        selectedButton?.layer.borderWidth = 7
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}

