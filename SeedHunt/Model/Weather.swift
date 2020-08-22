//
//  ForecastWeather.swift
//  SeedHunt
//
//  Created by Weijie Li on 11/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation
import UIKit

struct Weather {
  var current: DarkSky?
  var daily: [DarkSky]?
  
  init() {}
  
  init?(json: [String: Any]) {
    guard let jsonCurrent = json["currently"] as? [String: Any] else { return nil }
    
    current = DarkSky(json: jsonCurrent)
    
    if let jsonDaily = json["daily"] as? [String: Any],
      let dailyDatas = jsonDaily["data"] as? [[String: Any]] {
      daily = []
      dailyDatas.forEach {
        daily!.append(DarkSky(json: $0))
      }
    }
  }
}

extension Weather {
  static let fetchPath = "api/ds"
  static let fetchPathMoon = "api/moon"
}

struct DarkSky: Identifiable {
  var dt: Date?
  var summary: String? // "Rain starting in the afternoon, continuing until evening."
  var icon: String?   // "rain"
  var precipIntensity: Double?    // Millimeters per hour
  var precipIntensityMax: Double? // Millimeters per hour
  var precipProbability: Double?  // [0,1]
  var precipType: String? // "rain", "snow", or "sleet"
  var apparentTemperatureLow: Double? // Celsius
  var apparentTemperatureHigh: Double? // Celsius
  var windSpeed: Double?  // Meters per second
  var windBearing: Int?   // degrees true north at 0° and progressing clockwise
  var cloudCover: Double? // [0,1]
  
  var temperature: Double?    // Celsius, only for currently
  
  // daily
  var sunriseTime: Date?
  var sunsetTime: Date?
  var moonPhase: Double?
  var moonMove: String? // "ascending" or "descending"
  var moonActions: [String]?
  
  // Identifiable
  var id = UUID()
  
  init() {}
  
  init(json: [String: Any]) {
    if let time = json["time"] as? Int {
      dt = Date(timeIntervalSince1970: TimeInterval(time))
    }
    summary = json["summary"] as? String
    icon = json["icon"] as? String
    precipIntensity = json["precipIntensity"] as? Double
    precipIntensityMax = json["precipIntensityMax"] as? Double
    precipType = json["precipType"] as? String
    precipProbability = json["precipProbability"] as? Double
    apparentTemperatureLow = json["apparentTemperatureLow"] as? Double
    apparentTemperatureHigh = json["apparentTemperatureHigh"] as? Double
    windSpeed = json["windSpeed"] as? Double
    windBearing = json["windBearing"] as? Int
    cloudCover = json["cloudCover"] as? Double
    
    temperature = json["temperature"] as? Double
    
    if let sunrise = json["sunriseTime"] as? Int {
      sunriseTime = Date(timeIntervalSince1970: TimeInterval(sunrise))
    }
    if let sunset = json["sunsetTime"] as? Int {
      sunsetTime = Date(timeIntervalSince1970: TimeInterval(sunset))
    }
    moonPhase = json["moonPhase"] as? Double
  }
}

extension DarkSky {
  var systemIcon: String? {
    switch icon {
    case "clear-day":
      return "sun.max"
    case "clear-night":
      return "moon.stars"
    case "rain":
      return "cloud.rain"
    case "snow":
      return "cloud.snow"
    case "sleet":
      return "cloud.sleet"
    case "wind":
      return "wind"
    case "fog":
      return "cloud.fog"
    case "cloudy":
      return "smoke"
    case "partly-cloudy-day":
      return "cloud.sun"
    case "partly-cloudy-night":
      return "cloud.moon"
    default:
      return nil
    }
  }
  
  var moonIcon: String? {
    guard let moonPhase = moonPhase else { return nil }
    
    var name: String? = nil
    if (moonPhase == 0) { name = "new-moon" }
    else if (moonPhase < 0.25) { name = "waxing-crescent" }
    else if (moonPhase == 0.25) { name = "first-quarter" }
    else if (moonPhase < 0.5) { name = "waxing-gibbous" }
    else if (moonPhase == 0.5) { name = "full-moon" }
    else if (moonPhase < 0.75) { name = "waning-gibbous" }
    else if (moonPhase == 0.75) { name = "last-quarter" }
    else if (moonPhase < 1) { name = "waning-crescent" }
    
    
    return name
  }
}
