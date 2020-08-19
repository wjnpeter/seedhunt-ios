//
//  SearchView.swift
//  SeedHunt
//
//  Created by Weijie Li on 15/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import GooglePlaces
import CoreLocation

struct SearchView: View {
  
  @State private var searchResults = PlacePickerResultType()
  
  @Binding var selection: Location
  @Binding var showSearchView: Bool
  
  var body: some View {
    VStack {
      PlacePicker(results: $searchResults)
      
      currentLocView()
      
      List {
        ForEach(searchResults, id: \.placeID) { result in
          self.searchLocView(for: result)
        }
      }
      
      Text("Popular")
      List {
        ForEach(LocationHelper.popularLocations, id: \.name) { loc in
          self.popularLocView(for: loc)
        }
      }
    }
    .onAppear {
      LocationHelper.shared.authorize()
    }
  }
  
  private func currentLocView() -> some View {
    Text("Current Location")
      .onTapGesture {
        LocationHelper.shared.userLocation { userLocation in
          self.select(userLocation)
        }
      }
  }
  
  private func searchLocView(for item: GMSAutocompletePrediction) -> some View {
    // TODO support attributed text
    Group {
      Text(item.attributedFullText.string)
    }
    .onTapGesture {
      
      GMSPlacesClient.shared().lookUpPlaceID(item.placeID, callback: { (place, err) in
        if let place = place {
          if let metaData = place.photos?.first {
            GMSPlacesClient.shared().loadPlacePhoto(metaData) { (photo, _) in
              self.select(Location.make(with: place.coordinate, name: place.name, photo: photo))
            }
          } else {
            self.select(Location.make(with: place.coordinate, name: place.name))
          }
          
        }
      })
    }
  }
  
  private func popularLocView(for loc: Location) -> some View {
    Group {
      OptionalText(loc.name)
    }
    .onTapGesture {
      self.select(loc)
    }
  }
  
  private func select(_ selection: Location) {
    self.selection = selection
    showSearchView = false
  }
  
}
