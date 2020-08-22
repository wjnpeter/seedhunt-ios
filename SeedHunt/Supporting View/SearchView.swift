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
  @Binding var seedFilter: SeedFilter
  @Binding var showSearchView: Bool
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      PlacePicker(results: $searchResults)
      
      VStack(alignment: .leading) {
        
        currentLocView()
        Divider()
        
        if !searchResults.isEmpty {
          caption("Google Search")
            
          ForEach(searchResults, id: \.placeID) { result in
            self.searchLocView(for: result)
          }
        }
        
        caption("Popular")
          
        ForEach(LocationHelper.popularSearches) { popularSearch in
          PopularSearchView(popularSearch: popularSearch)
        }
      }
      .padding()
    }
    .onAppear {
      LocationHelper.shared.authorize()
    }
    .gesture(DragGesture().onChanged({ _ in
      // dismiss keyboard
      UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }))
  }
  
  private func caption(_ text: String) -> some View {
    Text(text)
      .font(.callout)
      .bold()
      .padding(.top, Style.spacing.superview)
  }
  
  private func currentLocView() -> some View {
      Button(action: {
        LocationHelper.shared.userLocation { userLocation in
          self.select(userLocation)
        }
      }) {
        HStack {
          Image(systemName: "location")
          Text("Use My Current Location")
        }
      }
    
  }
  
  private func searchLocView(for item: GMSAutocompletePrediction) -> some View {
    // TODO support attributed text
    Group {
      HStack {
        Image(systemName: "magnifyingglass")
        Label(item.attributedFullText)
      }
      Divider()
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
  
  private func select(_ selection: Location) {
    self.selection = selection
    showSearchView = false
  }
  
}

extension SearchView {
  
  struct PopularSearchView: View {
    let popularSearch: LocationHelper.PopularSearch
    
    @ObservedObject private var viewModel: ViewModel
    
    init(popularSearch: LocationHelper.PopularSearch) {
      self.popularSearch = popularSearch
      
      self.viewModel = ViewModel(location: popularSearch.location)
      self.viewModel.seedFilter.category = popularSearch.category
      
      self.viewModel.fetchZone(about: "temperature")
    }
    
    private var category: String {
      popularSearch.category.rawValue
    }
    
    private var city: String {
      popularSearch.location.name!
    }
    
    var body: some View {
      HStack {
        Image(category)
          .resizable()
          .frame(width: 50, height: 50, alignment: .center)
          .aspectRatio(1, contentMode: .fit)
          .cornerRadius(Style.shape.cornerRadius)
        
        VStack(alignment: .leading) {
          Text("\(category.capitalized) in \(city.capitalized)")
            .font(.headline)
            .foregroundColor(Color(UIColor.label))
          
          Text("\(viewModel.filterSeeds.count) Plants")
            .font(.body)
            .foregroundColor(Color(UIColor.secondaryLabel))
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .padding()
      .border(Color(UIColor.systemGray2))
      .cornerRadius(Style.shape.cornerRadius)
    }
  }
}
