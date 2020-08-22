//
//  PlacePicker.swift
//  SeedHunt
//
//  Created by Weijie Li on 4/6/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import UIKit
import GooglePlaces

typealias PlacePickerResultType = [GMSAutocompletePrediction]

struct PlacePicker: UIViewRepresentable {
  @Binding var results: PlacePickerResultType
  
  func makeUIView(context: Self.Context) -> UISearchBar {
    let searchBar = UISearchBar()
    searchBar.delegate = context.coordinator
    return searchBar
  }
  
  func updateUIView(_ uiView: UISearchBar, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(results: $results)
  }
  
  class Coordinator: NSObject, UISearchBarDelegate, GMSAutocompleteFetcherDelegate {
    
    @Binding var results: PlacePickerResultType
    
    private var fetcher: GMSAutocompleteFetcher?
    
    init(results: Binding<PlacePickerResultType>) {
      self._results = results
      super.init()
      
      GMSPlacesClient.provideAPIKey("AIzaSyD3YFF_ssj5ZGYCyEd64SQeq5TESyhFWtY")
      
      let filter = GMSAutocompleteFilter()
      filter.type = .city
      filter.country = "au"
      fetcher = GMSAutocompleteFetcher(filter: filter)
      fetcher!.delegate = self
    }
    
    //UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
         searchBar.setShowsCancelButton(false, animated: true)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
         searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
         searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      fetcher?.sourceTextHasChanged(searchText)
    }
    
    // GMSAutocompleteFetcherDelegate
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
      results = predictions
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
      // TODO
    }
  }
  
  
}
