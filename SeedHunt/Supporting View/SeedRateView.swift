//
//  SeedRateView.swift
//  SeedHunt
//
//  Created by Weijie Li on 20/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct SeedRateView: View {
  let rate: Double?
  
  private var countFilled: Int { Int(rate ?? 0) }
  
  private var countHalf: Int {
    guard let rate = rate else { return 0 }
    return rate.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1
  }
  
  private var countEmpty: Int {
    5 - countFilled - countHalf
  }
  
  var body: some View {
    HStack(spacing: 1) {
      ForEach(0..<countFilled, id: \.self) { _ in
        Image(systemName: "circle.fill")
      }
      
      ForEach(0..<countHalf, id: \.self) { _ in
        Image(systemName: "circle.lefthalf.fill")
      }
      
      ForEach(0..<countEmpty, id: \.self) { _ in
        Image(systemName: "circle")
      }
    }
    .foregroundColor(Color.secondary)
  }
}

struct SeedRateView_Previews: PreviewProvider {
  static var previews: some View {
    SeedRateView(rate: 3.5)
  }
}
