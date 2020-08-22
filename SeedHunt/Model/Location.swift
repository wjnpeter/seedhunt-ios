//
//  Location.swift
//  SeedHunt
//
//  Created by Weijie Li on 19/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct Location {
  var coordinate: CLLocationCoordinate2D
  var name: String?
  var photo: UIImage?
  
  func latLon() -> String {
    return "\(latitude),\(longitude)"
  }
  
  var latitude: CLLocationDegrees {
    coordinate.latitude
  }
  
  var longitude: CLLocationDegrees {
    coordinate.longitude
  }
  
  static func make(with coordinate: CLLocationCoordinate2D, name: String? = nil, photo: UIImage? = nil) -> Location {
    return Location(coordinate: coordinate, name: name, photo: photo)
  }
  
  
}
