//
//  CalendarViews.swift
//  SeedHunt
//
//  Created by Weijie Li on 15/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct CalendarViewWithRange: View {
  var start: Date
  var length: Int
  
  @Binding var selection: Date?
  
  @Environment(\.calendar) var calendar
  
  @State private var rowsOfDates: [[Date?]] = []
  
  var body: some View {
    VStack {
      ForEach(rowsOfDates, id: \.self) { (row) in
        VStack {
          
          self.view(for: row)
          Divider()
        }
      }
      
    }
    .onAppear {
      self.updateRows()
    }
  }
  
  private func view(for row: [Date?]) -> some View {
    HStack {
      ForEach(row, id: \.self) { dt in
        self.view(for: dt)
         
      }
    }
  }
  
  private func view(for date: Date?) -> some View {
    ZStack {
      backgroundView(for: date)
      
      Group {
        if date != nil {
          Text(String(self.calendar.component(.day, from: date!)))
            .onTapGesture {
              self.selection = date!
            }
        }
      }
    }
  }
  
  private func backgroundView(for date: Date?) -> some View {
    Group {
      if date == nil {
        Circle().foregroundColor(Color.clear)
      } else if selection != nil &&
        calendar.isDate(date!, equalTo: selection!, toGranularity: .day) {
        Circle().foregroundColor(Color.orange)
      } else if calendar.isDate(date!, equalTo: Date(), toGranularity: .day) {
        Circle().foregroundColor(Color.gray)
      } else {
        Circle().foregroundColor(Color.clear)
      }
    }
  }
  
  private func updateRows() {
    rowsOfDates.removeAll(keepingCapacity: true)
    
    var row = Array<Date?>(repeating: nil, count: 7)
    for i in 0..<length {
      let dtDayMonthYear = calendar.date(byAdding: .day, value: i, to: start)
      
      let weekDay = calendar.component(.weekday, from: dtDayMonthYear!)
      
      row[weekDay-1] = dtDayMonthYear
      if weekDay == 7 {
        rowsOfDates.append(row)
        
        row = Array<Date?>(repeating: nil, count: 7)
      }
    }
    
    rowsOfDates.append(row)
  }
}

struct CalendarViewWeek: View {
  var start: Date
  
  @Binding var selection: Date?
  
  @Environment(\.calendar) var calendar
  
  var body: some View {
    CalendarViewWithRange(start: start, length: 7, selection: $selection)
  }
}

struct CalendarViewMonth: View {
  var month: Int
  var year: Int
  
  @Binding var selection: Date?
  
  @Environment(\.calendar) var calendar
  
  var body: some View {
    CalendarViewWithRange(start: firstDayOfMont(), length: daysOfMonth().count, selection: $selection)
  }
  
  private func firstDayOfMont() -> Date {
    var dayMonthYear = DateComponents()
    dayMonthYear.year = year
    dayMonthYear.month = month
    dayMonthYear.day = 1
    
    return calendar.date(from: dayMonthYear)!
  }
  
  private func daysOfMonth() -> Range<Int> {
    var monthYear = DateComponents()
    monthYear.year = year
    monthYear.month = month
    
    let dtIncluded = selection != nil ? selection! : calendar.date(from: monthYear)!
    return calendar.range(of: .day, in: .month, for: dtIncluded)!
  }
}
