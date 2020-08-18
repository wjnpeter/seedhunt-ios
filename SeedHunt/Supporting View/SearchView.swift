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
          self.select(Location.make(with: place.coordinate, name: place.name))
        }
      })
    }
  }
  
  private func select(_ selection: Location) {
    self.selection = selection
    showSearchView = false
  }
}
