//
//  MoonView.swift
//  SeedHunt
//
//  Created by Weijie Li on 14/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct MoonView: View {
  let daily: [DarkSky]?
  
  @State private var selectedDate: Date? = Date()
  
  @Environment(\.calendar) var calendar
  
  private var selectedData: DarkSky? {
    guard let daily = daily else { return nil }
    
    let idx = daily.firstIndex { calendar.isDate($0.dt!, equalTo: selectedDate!, toGranularity: .day) }
    if idx == nil { return nil }
    
    return daily[idx!]
  }
  
  private var moonIcons: [String]? {
    daily?.map { $0.moonIcon ?? "" }
  }
  
  var body: some View {
    VStack {
      if selectedData != nil {
        // calendar
        calendarTitleView
        HStack {
          ForEach(calendar.shortWeekdaySymbols, id: \.self) { monthSymbol in
            Text(monthSymbol)
              .frame(maxWidth: .infinity)
              .font(.caption)
          }
        }
        CalendarViewWithRange(start: selectedDate!, length: daily!.count, icons: moonIcons, selection: $selectedDate)
        
        Divider()
        caption("Suggestions")
        moonActionsView
        
      }
    }
    .navigationBarTitle("Moon")
  }
  
  private func caption(_ text: String) -> some View {
    OptionalText(text)
      .font(.subheadline)
  }
  
  private var calendarTitleView: some View {
    let dtFmt = DateFormatter()
    dtFmt.dateFormat = "MMM yyyy"
    dtFmt.timeZone = calendar.timeZone
    
    return caption(selectedDate != nil ? dtFmt.string(from: selectedDate!) : "")
      .padding(.bottom, Style.spacing.siblings)
  }
  
  
  private var moonIcon: some View {
    Group {
      if selectedData?.moonIcon != nil {
        Image(selectedData!.moonIcon!)
          .frame(minHeight: 100, maxHeight: .infinity)
      }
    }
  }
  
  private var moonActionsView: some View {
    List {
      if selectedData?.moonActions != nil {
        ForEach(selectedData!.moonActions!, id: \.self) { action in
          VStack(alignment: .leading) {
            Text(action)
          }
        }
      }
    }
  }
}

