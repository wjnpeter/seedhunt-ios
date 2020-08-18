//
//  Zone.swift
//  SeedHunt
//
//  Created by Weijie Li on 11/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation

struct Zone {
  var code: Int?
  var descript: String
  
  init() {
    self = Zone(code: nil, descript: String())
  }
  
  init(code: Int?, descript: String) {
    self.code = code
    self.descript = descript
  }

  init?(json: [String: Any]) {
    guard let code = json["code"] as? String else { return nil }
    guard let descriptObj = json["descript"] else { return nil }
    
    var descript = descriptObj as? String
    if descript == nil,
      let descripts = descriptObj as? [String] {
      descript = descripts.first
    }
    
    guard descript != nil else { return nil }
    
    self = Zone(code: Int(code), descript: descript!)
  }
  
}

extension Zone {
  static let fetchPath = "api/zone"
}
