//
//  LocationHelper.swift
//  SeedHunt
//
//  Created by Weijie Li on 18/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces

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
      makeLocation(with: lastLocation, completion: completion)
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
    
    GMSPlacesClient.shared().currentPlace { (places, _) in
      if let place = places?.likelihoods.first?.place {
        if let metaData = place.photos?.first {
          GMSPlacesClient.shared().loadPlacePhoto(metaData) { (photo, _) in
            completion?(Location.make(with: place.coordinate, name: place.name, photo: photo))
          }
        } else {
          completion?(Location.make(with: place.coordinate, name: place.name))
        }
      } else if let lastLocation = self.lastLocation,
        Date().timeIntervalSince(lastLocation.timestamp) < self.invalidTimeInterval {
        self.makeLocation(with: lastLocation, completion: completion)
      } else {
        self.userLocationCompletion = completion
        LocationHelper.shared.locationManager.startUpdatingLocation()
      }
    }
      
  }
  
  // TODO 用这个方法生成的Location没有photo
  private func makeLocation(with clLocation: CLLocation?, completion: LocationHelperCompletion?) {
    let loc = clLocation ?? lastLocation
    if loc == nil {
      completion?(defaultLocation)
      return
    }
    
    CLGeocoder().reverseGeocodeLocation(loc!) { places, _ in
      var ret = Location.make(with: loc!.coordinate, name: nil)
      if let placeMark = places?.first {
        ret.name = placeMark.name
      }
      
      completion?(ret)
    }
  }
}

extension LocationHelper: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    makeLocation(with: locations.last!, completion: userLocationCompletion)
    
    assert(LocationHelper.shared.locationManager == manager)
    LocationHelper.shared.locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    authorizeCompletion?(status)
    authorizeCompletion = nil
  }
}

extension LocationHelper {
  static func makeDefault() -> Location {
    if let locName =  UserDefaults.standard.string(forKey: Constants.locName) {
      let locLat =  UserDefaults.standard.double(forKey: Constants.locLat)
      let locLon =  UserDefaults.standard.double(forKey: Constants.locLon)
      return Location.make(with: CLLocationCoordinate2DMake(locLat, locLon), name: locName)
    } else {
      return LocationHelper.sydney
    }
  }
  
  // MARK: Search
  
  struct PopularSearch: Identifiable {
    var category: Seed.Category
    var location: Location
    var id = UUID()
  }
  
  static var popularSearches: [PopularSearch] = {
    let locs = LocationHelper.popularLocations.shuffled()
    return locs.map { PopularSearch(category: Seed.Category.allCases.randomElement()!, location: $0) }
  }()
  
  // MARK: Popular Locations
  
  static var popularLocations: [Location] {
    [LocationHelper.hobart, LocationHelper.melbourne, LocationHelper.sydney,
     LocationHelper.brisbane, LocationHelper.adelaide, LocationHelper.perth]
  }
  
  // TODO add default image 好看的
  static let hobart = Location.make(with: CLLocationCoordinate2DMake(-42.8821, 147.3272), name: "hobart", photo: nil)
  static let melbourne = Location.make(with: CLLocationCoordinate2DMake(-37.8136, 144.9631), name: "melbourne")
  static let sydney = Location.make(with: CLLocationCoordinate2DMake(-33.8688, 151.2093), name: "sydney")
  static let brisbane = Location.make(with: CLLocationCoordinate2DMake(-27.470125, 153.021072), name: "brisbane")
  static let adelaide = Location.make(with: CLLocationCoordinate2DMake(-34.9285, 138.6007), name: "adelaide")
  static let perth = Location.make(with: CLLocationCoordinate2DMake(-31.9505, 115.8605), name: "perth")
  
}


