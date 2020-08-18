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
  let moon: [Moon]?
  
  @State private var selectedDate: Date? = Date()
  
  @Environment(\.calendar) var calendar
  
  private var selectedData: (DarkSky, Moon)? {
    guard let daily = daily, let moon = moon else { return nil }
    
    let idx = daily.firstIndex { calendar.isDate($0.dt!, equalTo: selectedDate!, toGranularity: .day) }
    if idx == nil { return nil }
    
    assert(idx! < moon.count)
    return (daily[idx!], moon[idx!])
  }
  
  var body: some View {
    VStack {
      if selectedData != nil {
        titleView
        
        moonIcon
        
        moonActionsView
        
        CalendarViewWeek(start: selectedDate!, selection: $selectedDate)
      }
    }
    .navigationBarTitle("Moon")
  }
  
  private var titleView: some View {
    let dtFmt = DateFormatter()
    dtFmt.dateFormat = "d MMM yyyy"
    dtFmt.timeZone = calendar.timeZone
    
    return Text(selectedDate != nil ? dtFmt.string(from: selectedDate!) : "")
  }
  
  private var moonIcon: some View {
    if let name = selectedData?.0.moonIcon,
      let uiimage = UIImage(named: name) {
      return Image(uiImage: uiimage)
    }
    
    return Image(uiImage: UIImage())
  }
  
  private var moonActionsView: some View {
    List {
      if selectedData?.1.action != nil {
        ForEach(selectedData!.1.action!, id: \.self) { action in
          Text(action)
        }
      }
    }
  }
}

