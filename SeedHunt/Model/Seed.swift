//
//  Seed.swift
//  SeedHunt
//
//  Created by Weijie Li on 11/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation

struct Seed: Hashable, Equatable {
  var name: String
  var category: Category?
  var rate: Double?
  
  // plan
  var germination: ClosedRange<Int>?
  var maturity: ClosedRange<Int>?
  
  // measure
  var depth: ClosedRange<Int>?
  var rowSpacing: ClosedRange<Int>?
  var spacing: ClosedRange<Int>?
  
  // care
  var sow: [String]?
  var frost: String?
  
  var wikiName: String?
  var wiki: Wiki?
  
  // z1: [0, 1, 2]
  var time = [SeedZone: [Int]]()
  
  func favourite() {
    var favourites = UserDefaults.standard.stringArray(forKey: Constants.favourites)
    if favourites == nil {
      favourites = []
    }
    
    if !favourites!.contains(name) {
      favourites?.append(name)
      UserDefaults.standard.set(favourites, forKey: Constants.favourites)
    }
  }
  
  func isFavourite() -> Bool {
    guard let favourites = UserDefaults.standard.stringArray(forKey: Constants.favourites) else {
      return false
    }
    
    return favourites.contains(name)
  }
  
  func months(for zone: Zone?) -> [Int] {
    guard let zone = zone else { return [] }
    guard let seedZone = SeedZone(zone: zone) else { return [] }
    return time[seedZone] ?? []
  }
  
  func rateDisplay() -> String? {
    guard let rate = rate else { return nil }
    
    let hardnesses = ["Very Easy", "Easy", "Average", "Hard", "Demanding"]
    guard Int(rate) < hardnesses.count else { return nil }
    
    return hardnesses[Int(rate)]
  }
  
  func monthsDisplay(for zone: Zone?) -> String? {
    let zoneMonths = months(for: zone)
    
    guard let range = ClosedRange(array: zoneMonths) else { return nil }
    
    let symbols = Calendar.current.shortMonthSymbols
    guard range.lowerBound <= symbols.count,
      range.upperBound <= symbols.count else { return nil }
    
    
    return "\(symbols[range.lowerBound-1])~\(symbols[range.upperBound-1])"
  }
  
  init(name: String) {
    self.name = name
  }
  
  init?(json: [String: Any]) {
    guard let name = json["name"] as? String else { return nil }
    
    self = Seed(name: name)
    
    if let time = json["time"] as? [String: [Int]] {
      time.forEach { zone, months in
        if let tz = SeedZone(rawValue: zone) {
          self.time[tz] = months
        }
      }
    }
    
    if let category = json["category"] as? String {
      self.category = Category(rawValue: category)
    }
    
    rate = json["rate"] as? Double
    germination = ClosedRange(array: json["germination"] as? [Int])
    maturity = ClosedRange(array: json["maturity"] as? [Int])
    
    depth = ClosedRange(array: json["depth"] as? [Int])
    rowSpacing = ClosedRange(array: json["rowSpacing"] as? [Int])
    spacing = ClosedRange(array: json["spacing"] as? [Int])
    
    sow = json["sow"] as? [String]
    frost = json["frost"] as? String
   
    wikiName = json["wikiName"] as? String
    wiki = Wiki(json: json["wiki"] as? [String: Any] ?? [:])
   
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
  
  static func == (lhs: Seed, rhs: Seed) -> Bool {
    lhs.name == rhs.name
  }
}

extension Seed {
  struct Wiki {
    //    var link
    var thumbnail: URL?
    var extract: String?
    var description: String?
    
    init?(json: [String: Any]) {
      if let thumbnailObject = json["thumbnail"] as? [String: Any],
        let thumbnailSource = thumbnailObject["source"] as? String {
        thumbnail = URL(string: thumbnailSource)
      }
      
      extract = json["extract"] as? String
      description = json["description"] as? String
    }
  }
}

extension Seed {
  enum Category: String, CaseIterable {
    case flower, herb, vegetable
  }
  
  enum SeedZone: String, CaseIterable {
    case z1, z2, z3, z4, z5, z6
    
    init?(zone: Zone) {
      guard let zoneCode = zone.code else { return nil }
      let matchCase = SeedZone.allCases.first{ $0.rawValue.contains(String(zoneCode)) }
      
      if matchCase == nil { return nil }
      
      self = matchCase!
    }
  }
}

extension Seed {
  static let fetchPath = "api/seeds"
}

extension Seed: Identifiable {
  var id: String { name }
}
