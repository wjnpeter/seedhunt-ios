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
  @State private var customTitle: Bool
  
  private var title: String {
    viewModel.location.name ?? ""
  }
  
  init(viewModel: ObservedObject<ViewModel>) {
    self._viewModel = viewModel
    
    _customTitle = State(initialValue: viewModel.wrappedValue.location.photo != nil)
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack {
        ZStack(alignment: .bottomLeading) {
          OptionalImage(uiImage: self.viewModel.location.photo)
            .frame(width: geometry.size.width, height: geometry.size.width * 9 / 16, alignment: .center)
          
          if self.customTitle {
            OptionalText(self.title)
              .padding(Style.spacing.superview)
              .foregroundColor(Color(UIColor.lightText))
              .font(Font.largeTitle.bold())
          }
        }
        
        Picker(selection: self.$selectedTag, label: EmptyView()) {
          Text("Weather").tag(0)
          Text("Agriculture").tag(1)
          Text("Soil").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        
        self.subheadline
        
        List {
          if self.selectedTag == 0 { self.weatherCards }
          else if self.selectedTag == 1 { self.agriCards }
          else if self.selectedTag == 2 { self.soilCards }
        }
        .onAppear {
          UITableView.appearance().separatorStyle = .none
        }
        .onDisappear {
          UITableView.appearance().separatorStyle = .singleLine
        }
        
      }
      .navigationBarTitle(Text(self.customTitle ? "" : self.title),
                          displayMode: self.customTitle ? .inline : .automatic)
      .navigationBarHidden(self.customTitle)
    }
  }
  
  private var subheadline: some View {
    Group {
      if self.selectedTag == 0 { Text("Historical Weather") }
      else if self.selectedTag == 1 { Text("Updated \(updatedTime)") }
      else if self.selectedTag == 2 { Text("Updated \(updatedTime)") }
    }
    .font(.caption)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.leading, Style.spacing.superview)
  }
  
  private var updatedTime: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d/MMM 09:mm:ss"
    return dateFormatter.string(from: viewModel.fetchTime)
  }
  
  private var soilCards: some View {
    Group {
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
    Group {
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
    Group {
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
  
  private func icon(_ product: BOMProduct) -> String? {
    switch product {
    case .rainfallMonthly, .rainfallDaily:
      return "drop"
    case .maxtemperatureMonthly, .maxtemperatureDaily:
      return "thermometer.sun"
    case .mintemperatureMonthly, .mintemperatureDaily:
      return "thermometer.snowflake"
    case .terrTemperature:
      return "snow"
    case .evaporation:
      return "drop"
    case .sunshine:
      return "sun.min"
    }
  }
}

extension CityDetailView {
  
  struct StatCard: View {
    var icon: String? = nil
    var title: String
    var number: Double
    var unit: String
    var numberDesc: String? = nil
    
    var body: some View {
      ZStack {
        
        RoundedRectangle(cornerRadius: Style.shape.cornerRadius)
          .foregroundColor(Color(UIColor.systemGroupedBackground))
        
        HStack(alignment: .center) {
          OptionalImage(systemName: icon)
            .font(.system(size: 50))
            
            .offset(x: 0, y: -Style.spacing.superview * 2.5)
          
          Text(title)
            .font(.body)
          
          Spacer()
          
          VStack(alignment: .trailing) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
              Text(String(Int(number)))
                .font(.largeTitle)
              Text(unit)
                .font(.body)
            }
            
            OptionalText(numberDesc)
              .font(Font.footnote)
          }
        }
        .padding(horizontal: Style.spacing.siblings, vertical: Style.spacing.superview)
      }
      .padding(.top, icon != nil ? Style.spacing.superview * 2 : 0)
      
    }
    
  }
  
}
