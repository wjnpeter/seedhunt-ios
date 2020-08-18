//
//  LocationHelper.swift
//  SeedHunt
//
//  Created by Weijie Li on 18/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation
import CoreLocation

// conmunicate with Core Location
// eg. fetch user location


typealias LocationHelperCompletion = (Location) -> Void

class LocationHelper: NSObject {
  static let shared = LocationHelper()
  private override init() { super.init() }
  
  lazy var locationManager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.delegate = self
    return manager
  }()
  
  private var lastLocation: CLLocation? {
    locationManager.location
  }
  
  var defaultLocation: Location {
    LocationHelper.sydney
  }
  
  private var authorizeCompletion: ((CLAuthorizationStatus) -> Void)?
  
  func authorize(completion: ((CLAuthorizationStatus) -> Void)? = nil) {
    locationManager.requestWhenInUseAuthorization()
    authorizeCompletion = completion
  }
  
  private let invalidTimeInterval = TimeInterval(60*10)
  private var userLocationCompletion: LocationHelperCompletion?
  
  func userLocation(completion: LocationHelperCompletion?) {
    switch CLLocationManager.authorizationStatus() {
    case .denied, .restricted:
      finalisedUserLocation(with: lastLocation, completion: completion)
      return
    case .notDetermined:
      authorize { status in
        if status == .authorizedAlways || status == .authorizedWhenInUse {
          self.userLocation(completion: completion)
        }
      }
      return
    default:
      break;
    }
    
    if let lastLocation = lastLocation,
      Date().timeIntervalSince(lastLocation.timestamp) < invalidTimeInterval {
      finalisedUserLocation(with: lastLocation, completion: completion)
      return
    }
    
    userLocationCompletion = completion
    LocationHelper.shared.locationManager.startUpdatingLocation()
  }
  
  private func finalisedUserLocation(with clLocation: CLLocation?, completion: LocationHelperCompletion?) {
    let loc = clLocation ?? lastLocation
    if loc == nil {
      completion?(defaultLocation)
      return
    }
    
    CLGeocoder().reverseGeocodeLocation(loc!) { places, _ in
      let ret = Location.make(with: loc!.coordinate, name: nil)
      if let placeMark = places?.first {
        ret.name = placeMark.name
      }
      
      completion?(ret)
    }
  }
}

extension LocationHelper: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    finalisedUserLocation(with: locations.last!, completion: userLocationCompletion)
    
    assert(LocationHelper.shared.locationManager == manager)
    LocationHelper.shared.locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    authorizeCompletion?(status)
    authorizeCompletion = nil
  }
}

extension LocationHelper {
  // MARK: Popular Locations
  
  static let hobart = Location.make(with: CLLocationCoordinate2DMake(-42.8821, 147.3272), name: "hobart")
  static let melbourne = Location.make(with: CLLocationCoordinate2DMake(-37.8136, 144.9631), name: "melbourne")
  static let sydney = Location.make(with: CLLocationCoordinate2DMake(-33.8688, 151.2093), name: "sydney")
  static let brisbane = Location.make(with: CLLocationCoordinate2DMake(-27.470125, 153.021072), name: "brisbane")
  static let adelaide = Location.make(with: CLLocationCoordinate2DMake(-34.9285, 138.6007), name: "adelaide")
  static let perth = Location.make(with: CLLocationCoordinate2DMake(-31.9505, 115.8605), name: "perth")
  
}
