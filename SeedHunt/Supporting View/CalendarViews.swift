//
//  CalendarViews.swift
//  SeedHunt
//
//  Created by Weijie Li on 15/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct CalendarViewWithRange: View {
  let start: Date
  let length: Int
  var icons: [String]?
  
  @Binding var selection: Date?
  private func isSelected(_ dt: Date?) -> Bool {
    dt != nil && selection != nil && calendar.isDate(dt!, equalTo: selection!, toGranularity: .day)
  }
  private func isToday(_ dt: Date?) -> Bool {
    dt != nil && calendar.isDate(dt!, equalTo: Date(), toGranularity: .day)
  }
  
  @Environment(\.calendar) var calendar
  
  @State private var rowsOfDates: [[Cell?]] = []
  
  private struct Cell: Identifiable, Hashable {
    let dt: Date
    var icon: String?
    
    var id: TimeInterval {
      dt.timeIntervalSince1970
    }
    
    init?(_ dt: Date?, icon: String?) {
      guard let dt = dt else { return nil }
      self.dt = dt
      self.icon = icon
    }
  }
  
  var body: some View {
    VStack {
      ForEach(rowsOfDates, id: \.self) { (row) in
        self.view(for: row)
      }
      
    }
    .onAppear {
      self.updateRows()
    }
  }
  
  private func view(for row: [Cell?]) -> some View {
    HStack {
      ForEach(row, id: \.self) { cell in
        self.view(for: cell)
      }
    }
  }
  
  private func view(for dateCell: Cell?) -> some View {
    Group {
      if dateCell != nil && dateCell?.icon == nil {
        ZStack {
          backgroundView(for: dateCell?.dt)
          
          Text(String(self.calendar.component(.day, from: dateCell!.dt)))
            .font(.body)
            .onTapGesture {
              self.selection = dateCell!.dt
          }
        }
      } else if dateCell?.icon != nil {
        
        VStack(spacing: 1) {
          OptionalImage(name: dateCell?.icon)
            .aspectRatio(contentMode: .fit)
            .onTapGesture {
              self.selection = dateCell!.dt
            }
          
          Text(String(self.calendar.component(.day, from: dateCell!.dt)))
            .underline(isSelected(dateCell!.dt), color: Color.systemFill)
            .font(.footnote)
        }
      } else {
        backgroundView(for: nil)
      }
    }
  }
  
  private func backgroundView(for date: Date?) -> some View {
    Group {
      if isSelected(date) {
        Circle().foregroundColor(Color.secondarySystemFill)
      } else if isToday(date) {
        Circle().foregroundColor(Color.tertiarySystemFill)
      } else {
        Circle().aspectRatio(1, contentMode: .fit).foregroundColor(Color.clear)
      }
    }
  }
  
  private func updateRows() {
    rowsOfDates.removeAll(keepingCapacity: true)
    
    var row = Array<Cell?>(repeating: nil, count: 7)
    for i in 0..<length {
      let dtDayMonthYear = calendar.date(byAdding: .day, value: i, to: start)
      
      let weekDay = calendar.component(.weekday, from: dtDayMonthYear!)
      
      row[weekDay-1] = Cell(dtDayMonthYear, icon: icons?[i])
      if weekDay == 7 {
        rowsOfDates.append(row)
        
        row = Array<Cell?>(repeating: nil, count: 7)
      }
    }
    
    if row.contains(where: { $0 != nil }) {
      rowsOfDates.append(row)
    }
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
