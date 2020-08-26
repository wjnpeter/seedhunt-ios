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
            VStack(alignment: .leading) {
              OptionalText(self.day(of: ds.dt))
              
              OptionalText(ds.summary)
                .font(.subheadline)
                .foregroundColor(Color(UIColor.secondaryLabel))
            }
            
            Spacer(minLength: Style.spacing.siblings)
            
            if ds.apparentTemperatureLow != nil {
              OptionalText("\(Int(ds.apparentTemperatureHigh!))")
            }
            
            if ds.apparentTemperatureHigh != nil {
              OptionalText("| \(Int(ds.apparentTemperatureLow!))")
                .foregroundColor(Color(UIColor.secondaryLabel))
            }
            
            OptionalImage(systemName: ds.systemIcon)
              .frame(maxWidth: 36, maxHeight: 36)
              .aspectRatio(contentMode: .fit)
              .font(.body)
             
          }
          .padding(.top, Style.spacing.superview)
        }
      }
    }
    .navigationBarTitle("Weather")
    .font(.body)
    .foregroundColor(Color(UIColor.label))

  }
  
  private func day(of date: Date?) -> String? {
    guard let date = date else { return nil }
    
    if Calendar.current.isDate(date, inSameDayAs: Date()) {
      return "Today"
    } else {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEEE"
      return dateFormatter.string(from: date).capitalized
    }
  }
}


struct WeatherView_Previews: PreviewProvider {
  static var previews: some View {
    var w = Weather()
    w.daily = []
    
    var ds = DarkSky()
    ds.dt = Date()
    ds.summary = "Partly cloudy througout the day and the day"
    ds.apparentTemperatureLow = 10
    ds.apparentTemperatureHigh = 20
    ds.icon = "rain"
    
    w.daily?.append(ds)
    w.daily?.append(ds)
    return WeatherView(weather: w)
  }
}
