//
//  Agriculture.swift
//  SeedHunt
//
//  Created by Weijie Li on 11/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation

struct Agriculture {
  @Once var maxTemp: Double?
  @Once var minTemp: Double?
  @Once var terrTemp: Double?
  @Once var precip: Double?
  @Once var evaporation: Double?
  @Once var sunshine: Double?
  @Once var wetbulbTemp: Double?
  @Once var solar: Double?
  var soil = Soil()
  
  struct Soil {
    @Once var t5: Double?
    @Once var t10: Double?
    @Once var t20: Double?
    @Once var t50: Double?
    @Once var t1m: Double?
  }
  
  static let fetchPath = "api/bomagri"
  
  mutating func merge(from json: [String: Any]) {
    guard let data = json["data"] as? [String: Any] else { return }
    guard let agri = data["agri"] as? [String: Any] else { return }
    
    maxTemp = agri["maxTemp"] as? Double
    minTemp = agri["minTemp"] as? Double
    terrTemp = agri["terrTemp"] as? Double
    precip = agri["precip"] as? Double
    evaporation = agri["evaporation"] as? Double
    sunshine = agri["sunshine"] as? Double
    wetbulbTemp = agri["wetbulbTemp"] as? Double
    solar = agri["solar"] as? Double
    
    if let soil = agri["soilTemp"] as? [String: Any] {
      self.soil.t5 = soil["t5"] as? Double
      self.soil.t10 = soil["t10"] as? Double
      self.soil.t20 = soil["t20"] as? Double
      self.soil.t50 = soil["t50"] as? Double
      self.soil.t1m = soil["t1m"] as? Double
    }
  }
}
