//
//  TitleVC.swift
//  Wheelchair Workout
//
//  Created by User on 2/27/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import UIKit

class ViewController: ResponsiveTextFieldViewController {

  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet var weightUnitsLabels: [UILabel]!
  @IBOutlet weak var userWeight: UITextField!
  @IBOutlet weak var wheelchairWeight: UITextField!
  @IBOutlet weak var unitsSwitch: UISwitch!
  @IBOutlet weak var startButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initSettingButton()
    self.startButton.layer.borderColor = UIColor.blackColor().CGColor
    let defaults = NSUserDefaults.standardUserDefaults()
    if let labelText = defaults.objectForKey("weightUnits") as? String {
      self.updateWeightUnitLabels(labelText)
    }
    self.userWeight.text = String(defaults.integerForKey("userWeight"))
    self.wheelchairWeight.text = String(defaults.integerForKey("wheelchairWeight"))
    if let units = defaults.objectForKey("weightUnits") as? String {
      if units == "lbs"  {
        self.unitsSwitch.on = true
      }
      else {
        self.unitsSwitch.on = false
      }
    }
  }

  @IBAction func startButtonPressed(sender: UIButton) {
    performSegueWithIdentifier("toExerciseVC", sender: self)
  }
  
  @IBAction func unitSwitch(sender: UISwitch) {
    if sender.on {
      self.updateWeightUnitLabels("lbs")
    }
    else {
      self.updateWeightUnitLabels("kg")
    }
  }
  
  func updateWeightUnitLabels(newText: String) {
    for weightLabel in self.weightUnitsLabels {
      weightLabel.text = newText
    }
  }
  
  func saveUserInfoToDefaults() {
    let defaults = NSUserDefaults.standardUserDefaults()
    let units = self.weightUnitsLabels[0].text
    defaults.setObject(units, forKey: "weightUnits")
    let weight = NSNumberFormatter().numberFromString(self.userWeight.text)!.doubleValue
    if (weight > 0)  {
      defaults.setDouble(weight, forKey: "userWeight")
    }
    let wcWeight = NSNumberFormatter().numberFromString(self.wheelchairWeight.text)!.doubleValue
    if (wcWeight > 0) {
      defaults.setDouble(wcWeight, forKey: "wheelchairWeight")
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "toExerciseVC" {
      self.saveUserInfoToDefaults()
      if let dlvc = segue.destinationViewController as? DistanceLoggerViewController {
        dlvc.userWeight = self.totalWeight()
      }
    
    }
  }
  
  func totalWeight() -> Double {
    let wWeight = (self.wheelchairWeight.text as NSString).doubleValue
    let uWeight = (self.userWeight.text as NSString).doubleValue
    return wWeight + uWeight
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    self.view.endEditing(true)
  }
  
  func initSettingButton() {
    self.settingsButton.setTitle(NSString(string: "\u{2699}"), forState: UIControlState.Normal)
    self.settingsButton.layer.cornerRadius = 5
    self.settingsButton.layer.borderWidth = 1
    self.settingsButton.layer.borderColor = UIColor.blackColor().CGColor
  }
}

