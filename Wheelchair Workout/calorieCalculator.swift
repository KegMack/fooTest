//
//  calorieCalculator.swift
//  Wheelchair Workout
//
//  Created by User on 3/8/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

// 1 Cal = 4200J, 1 mi = 1609m, 1kg = 2.20462lbs
// FLAT: weight 160lbs, 240 Cal/hr @ 2mph = 120 Cal/mi == 0.75 Cal/(lb*mi)
// = 0.00046613 Cal/(lb*m) = 0.00102764 Cal/(kg*m)

// UP: 0.0023333 Cal/kg*m or 0.00105838 Cal/lb*m

import Foundation
import CoreLocation

class CalorieCalculator {
   struct Constants{
    static let numDataPointsPerLocation = 5
    static let upCaloriesPerMeterKG = 0.00233333
    static let flatCaloriePerMeterKG = 0.00102764
    static let distanceKey = "distance"
    static let caloriesBurnedKey = "calories"
    static let notificationKeyForNewCalculation = "wheelchair workout has calorimetric data"
  }
  
  var dataPoints = [CLLocation]()
  var previousLocation: CLLocation?
  var currentLocation: CLLocation?
  var userWeight: Double = 0
  
  init() {
    self.currentLocation = nil
    self.previousLocation = nil
  }
  
  func addDataPoint(data: CLLocation?) {
    if let newData = data {
      self.dataPoints.append(newData)
      if self.dataPoints.count >= Constants.numDataPointsPerLocation {
        self.analyzeDataAndUpdateLocation()
        self.dataPoints.removeAll(keepCapacity: true)
      }
    }
  }
  
  private func analyzeDataAndUpdateLocation() {
    self.removeMaxAndMinAltitudes()
    self.updateLocation()
  }
  
  private func updateLocation() {
    if let newLocation = averageLocation() {
      previousLocation = currentLocation
      currentLocation = newLocation
      if previousLocation != nil {
        let distance = floor(currentLocation!.distanceFromLocation(previousLocation))
        //println("distance is a fucking peickl;fjl;adkflajk \(distance)")
        let altitudeChange = Double(currentLocation!.altitude) - Double(previousLocation!.altitude)
        let calories = calculateCaloriesBurned(distance, climb: altitudeChange)
        let dataOutput = [Constants.distanceKey:distance, Constants.caloriesBurnedKey:calories];
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.notificationKeyForNewCalculation, object: self, userInfo: dataOutput)
      }
    }
  }
  
  private func calculateCaloriesBurned(distance: Double, climb: Double) -> Double {
    var caloriesBurned: Double = 0
    let flatCals = distance * Constants.flatCaloriePerMeterKG * self.userWeight
    if climb >= 0 {
      let upCals = climb * Constants.upCaloriesPerMeterKG * self.userWeight
      caloriesBurned = flatCals + upCals
      
    }
    else {
      caloriesBurned = flatCals * 0.5
    }
    return caloriesBurned
  }
  
  private func removeMaxAndMinAltitudes() {
    var maxAltitude = self.dataPoints[0].altitude
    var maxIndex: Int = 0
    for (i, loc) in enumerate(self.dataPoints) {
      if loc.altitude > maxAltitude {
        maxAltitude = loc.altitude
        maxIndex = i
      }
    }
    self.dataPoints.removeAtIndex(maxIndex)
    var minAltitude = self.dataPoints[0].altitude
    var minIndex: Int = 0
    for (i, loc) in enumerate(self.dataPoints) {
      if loc.altitude < minAltitude {
        minAltitude = loc.altitude
        minIndex = i
      }
    }
    self.dataPoints.removeAtIndex(minIndex)
  }
  
  private func averageLocation() -> CLLocation? {
    var altitudes = [Double]()
    var latitudes = [Double]()
    var longitudes = [Double]()
    for loc in dataPoints {    
      altitudes.append(Double(loc.altitude))
      latitudes.append(Double(loc.coordinate.latitude))
      longitudes.append(Double(loc.coordinate.longitude))
    }
    let avgAltitude = floor(averageValue(altitudes))
    let avgLatitude = averageValue(latitudes)
    let avgLongitude = averageValue(longitudes)
    println("avg altitude \(avgAltitude)")
    return CLLocation(coordinate: CLLocationCoordinate2D(latitude: avgLatitude, longitude: avgLongitude), altitude: avgAltitude, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: NSDate())
  }

  private func averageValue(data:[Double]) -> Double {
    return data.reduce(0) {$0+$1} / Double(data.count)
  }
 }