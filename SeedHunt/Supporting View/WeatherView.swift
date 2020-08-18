//
//  WeatherView.swift
//  SeedHunt
//
//  Created by Weijie Li on 14/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct WeatherView: View {
  let weather: Weather?
  
  var body: some View {
    
    List {
      if weather?.daily != nil {
        ForEach(weather!.daily!) { ds in
          HStack {
            VStack {
              OptionalText(self.day(of: ds.dt))
              OptionalText(ds.summary)
            }
            
            OptionalText(ds.apparentTemperatureLow)
            Divider()
            OptionalText(ds.apparentTemperatureHigh)
            
            if ds.systemIcon != nil {
              OptionalImage(uiimage: UIImage(systemName: ds.systemIcon!))
            }
          }
        }
      }
    }
    .navigationBarTitle("Weather")
    
  }
  
  private func day(of date: Date?) -> String? {
    guard let date = date else { return nil }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: date).capitalized
    
  }
}

