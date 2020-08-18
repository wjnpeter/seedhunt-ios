//
//  HistoricalWeather.swift
//  SeedHunt
//
//  Created by Weijie Li on 13/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation

struct HistoricalWeather {
  var stat: MeanStat
  var ytd: MeanStat?
  
  static let fetchPath = "api/bomstat"
  
  init?(json: [String: Any]) {
    guard let data = json["data"] as? [String: Any] else { return nil }
    guard let stats = data["stats"] as? [String: Any] else { return nil }
    guard let meanStat = MeanStat(json: stats) else { return nil }
    
    stat = meanStat
    
    if let ytd = data["stats"] as? [String: Any] {
      self.ytd = MeanStat(json: ytd)
    }
  }
  
  struct MeanStat {
    var start: String
    var end: String
    var annual: Int
    var months: [Int]
    
    init(start: String, end: String, annual: Int, months: [Int]) {
      self.start = start
      self.end = end
      self.annual = annual
      self.months = months
    }
    
    init?(json: [String: Any]) {
      guard let start = json["start"] as? String else { return nil }
      guard let end = json["end"] as? String else { return nil }
      guard let annual = json["annual"] as? Int else { return nil }
      guard let months = json["months"] as? [Int] else { return nil }
      
      self = MeanStat(start: start, end: end, annual: annual, months: months)
    }
  }
}

struct BomStation {
  var id: String
  var name: String?
  
  static let fetchPath = "api/bomstn"
  
  init() {
    self = BomStation(id: String(), name: nil)
  }
  
  init(id: String, name: String?) {
    self.id = id
    self.name = name
  }
  
  init?(json: [String: Any]) {
    guard let data = json["data"] as? [String: Any] else { return nil }
    guard let station = data["station"] as? [String: String] else { return nil }
    
    guard let id = station["id"] else { return nil }
    
    self = BomStation(id: id, name: station["name"])
  }
}

enum BOMProduct: Int {
  case rainfallMonthly = 139
  case maxtemperatureMonthly = 36
  case mintemperatureMonthly = 38
  
  case rainfallDaily = 136
  case maxtemperatureDaily = 122
  case mintemperatureDaily = 123
  
  case terrTemperature = 124
  case evaporation = 125
  case sunshine = 133
}
