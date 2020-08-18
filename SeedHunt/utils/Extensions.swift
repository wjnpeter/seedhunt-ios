//
//  Extensions.swift
//  SeedHunt
//
//  Created by Weijie Li on 12/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


extension Location {
  func latLon() -> String? {
    return "\(latitude),\(longitude)"
  }
  
  var latitude: CLLocationDegrees {
    placemark.coordinate.latitude
  }
  
  var longitude: CLLocationDegrees {
    placemark.coordinate.longitude
  }
  
  static func make(with coordinate: CLLocationCoordinate2D, name: String?) -> Location {
    let ret = Location(placemark: MKPlacemark(coordinate: coordinate))
    ret.name = name
    
    return ret
  }
  
}

extension ClosedRange where Bound == Int {
  init?(array: [Int]?) {
    guard let array = array else { return nil }
    guard !array.isEmpty else { return nil }
    
    self.init(uncheckedBounds: (array.first!, array.last!))
  }
  
  func display(suffix: String = "") -> String {
    "\(lowerBound)~\(upperBound)\(suffix)"
  }
}
