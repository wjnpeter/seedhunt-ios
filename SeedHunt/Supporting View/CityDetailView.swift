//
//  CityDetailView.swift
//  SeedHunt
//
//  Created by Weijie Li on 13/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct CityDetailView: View {
  @ObservedObject var viewModel: ViewModel
  
  @State private var selectedTag = 0
  
  var body: some View {
    
    VStack {
      Picker(selection: self.$selectedTag, label: EmptyView()) {
        Text("Weather").tag(0)
        Text("Agriculture").tag(1)
        Text("Soil").tag(2)
      }
      .pickerStyle(SegmentedPickerStyle())
      
      if selectedTag == 0 { weatherCards }
      else if selectedTag == 1 { agriCards }
      else if selectedTag == 2 { soilCards }
    }
  }
  
  private var soilCards: some View {
    List {
      soilCard("5cm Depth", number: \.t5)
      soilCard("10cm Depth", number: \.t10)
      soilCard("20cm Depth", number: \.t20)
      soilCard("50cm Depth", number: \.t50)
      soilCard("1m Depth", number: \.t1m)
    }
  }
  
  private func soilCard(_ title: String, number: KeyPath<Agriculture.Soil, Double?>) -> some View {
    Group {
      if viewModel.agriculture.soil[keyPath: number] != nil {
        StatCard(icon: nil,
                 title: title,
                 number: viewModel.agriculture.soil[keyPath: number]!,
                 unit: "°C",
                 numberDesc: nil)
      }
    }
  }
  
  private var agriCards: some View {
    List {
      agriCard(.terrTemperature)
      agriCard(.sunshine)
      agriCard(.evaporation)
    }
  }
  
  private func agriCard(_ product: BOMProduct) -> some View {
    Group {
      if viewModel.agriValue(for: product) != nil {
        StatCard(icon: icon(.evaporation),
                 title: title(product),
                 number: viewModel.agriValue(for: product)!,
                 unit: unit(product),
                 numberDesc: nil)
      }
    }
  }
  
  private var weatherCards: some View {
    List {
      weatherCard(.rainfallMonthly)
      weatherCard(.maxtemperatureMonthly)
      weatherCard(.mintemperatureMonthly)
    }
  }
  
  private func weatherCard(_ product: BOMProduct) -> some View {
    Group {
      if weather(product) != nil {
        StatCard(icon: icon(product),
                 title: title(product),
                 number: Double(self.weather(product)!.stat.annual),
                 unit: unit(product),
                 numberDesc: "\(self.weather(product)!.stat.start)~\(self.weather(product)!.stat.end)")
      }
    }
  }
  
  private func weather(_ product: BOMProduct) -> HistoricalWeather? {
    viewModel.historicalWeathers[product]
  }
  
  private func title(_ product: BOMProduct) -> String {
    switch product {
    case .rainfallMonthly:
      return "Mean Rainfall"
    case .maxtemperatureMonthly:
      return "Mean Maximum Temperature"
    case .mintemperatureMonthly:
      return "Mean Minimum Temperature"
    case .terrTemperature:
      return "Overnight Temperature"
    case .evaporation:
      return "Evaporation"
    case .sunshine:
      return "Sunshine Hours"
    default:
      return ""
    }
  }
  
  private func unit(_ product: BOMProduct) -> String {
    switch product {
    case .rainfallMonthly, .rainfallDaily,
         .evaporation:
      return "mm"
    case .maxtemperatureMonthly, .maxtemperatureDaily,
         .mintemperatureMonthly, .mintemperatureDaily,
         .terrTemperature:
      return "°C"
    case .sunshine:
      return "hours"
    }
  }
  
  private func icon(_ product: BOMProduct) -> UIImage? {
    switch product {
    case .rainfallMonthly, .rainfallDaily:
      return UIImage(systemName: "drop")
    case .maxtemperatureMonthly, .maxtemperatureDaily:
      return UIImage(systemName: "thermometer.sun")
    case .mintemperatureMonthly, .mintemperatureDaily:
      return UIImage(systemName: "thermometer.snowflake")
    case .terrTemperature:
      return UIImage(systemName: "snow")
    case .evaporation:
      return UIImage(systemName: "drop")
    case .sunshine:
      return UIImage(systemName: "sun.min")
    }
  }
}

extension CityDetailView {
  
  struct StatCard: View {
    var icon: UIImage? = nil
    var title: String
    var number: Double
    var unit: String
    var numberDesc: String? = nil
    
    var body: some View {
      ZStack {
        RoundedRectangle(cornerRadius: 4)
          .foregroundColor(Color.red)
        
        HStack {
          OptionalImage(uiimage: icon)
          
          Text(title)
          
          VStack {
            HStack {
              Text(String(number))
              Text(unit)
            }
            
            OptionalText(numberDesc)
          }
        }
      }
    }
    
  }
  
}
