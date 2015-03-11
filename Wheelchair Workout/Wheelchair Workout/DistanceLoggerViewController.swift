//
//  DistanceLoggerViewController.swift
//  Wheelchair Workout
//
//  Created by User on 3/4/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import UIKit
import CoreLocation

class DistanceLoggerViewController: UIViewController, CLLocationManagerDelegate{

  @IBOutlet weak var speedBox: UILabel!
  @IBOutlet weak var altitudeBox: UILabel!
  @IBOutlet weak var latitudeBox: UILabel!
  @IBOutlet weak var longitudeBox: UILabel!
  
  var locationManager = CLLocationManager()
  var isUpdatingLocation = false
  var calCalc = CalorieCalculator()
  var totalCalories: Double = 0
  var totalDistance: Double  = 0
  var userWeight: Double = 0
  
  
  @IBAction func StartButtonPressed(sender: UIButton) {
    println("start")
    if(!self.isUpdatingLocation) {
      self.locationManager.startUpdatingLocation()
      self.isUpdatingLocation = true
      sender.setTitle("Pause", forState: UIControlState.Normal)
    }  else  {
      self.locationManager.stopUpdatingLocation()
      self.isUpdatingLocation = false
      sender.setTitle("Resume", forState: UIControlState.Normal)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.locationManager.delegate = self
    self.locationManager.activityType = CLActivityType.Fitness  // keep or remove??
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.pausesLocationUpdatesAutomatically = true
    self.locationManager.distanceFilter = 2
    self.calCalc.userWeight = userWeight
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "moreCaloriesBurned:", name: CalorieCalculator.Constants.notificationKeyForNewCalculation, object: nil)
    //NSNotificationCenter.defaultCenter().addObserver(self, selector: "moreCaloriesBurned:", name: CalorieCalculator.Constants.notificationKeyForNewCalculation(, object: nil)
  }
  
  func moreCaloriesBurned(notification:NSNotification) {
    if let userInfo = notification.userInfo as? Dictionary<String,Double> {
      self.totalCalories += userInfo[CalorieCalculator.Constants.caloriesBurnedKey]!;
      self.totalDistance += userInfo[CalorieCalculator.Constants.distanceKey]!
    }
  //  self.totalDistance += calCalc.distance
  //  self.totalCalories += calCalc.caloriesBurned
    self.longitudeBox.text = "\(self.totalDistance)m"
    self.latitudeBox.text = "\(self.totalCalories)kCal"


    println("calories burned: \(self.totalCalories)")
    println("distance: \(self.totalDistance)")
   // println("weight: \(self.userWeight)")
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    if let newLocation = locations.last as? CLLocation {
      //self.longitudeBox.text = "\(newLocation.coordinate.longitude)"
      //self.latitudeBox.text = "\(newLocation.coordinate.latitude)"
      self.altitudeBox.text = "\(newLocation.altitude) m"
      self.speedBox.text = "\(newLocation.speed) m/s"
      self.calCalc.addDataPoint(newLocation)
   // println("location = \(locations)")
    }
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
