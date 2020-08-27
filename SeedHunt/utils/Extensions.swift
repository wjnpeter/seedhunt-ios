//
//  Extensions.swift
//  SeedHunt
//
//  Created by Weijie Li on 12/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Combine
import SwiftUI

typealias CancellableBag = Set<AnyCancellable>
extension CancellableBag {
  mutating func cancelAll() {
    forEach { $0.cancel() }
    removeAll()
  }
}

extension ClosedRange where Bound == Int {
  init?(array: [Int]?) {
    guard let array = array else { return nil }
    guard !array.isEmpty else { return nil }
    
    self.init(uncheckedBounds: (array.first!, array.last!))
  }
  
  func display(suffix: String = "") -> String {
    "\(lowerBound)~\(upperBound)\(suffix)"
  }
}

extension EdgeInsets {
  init(horizontal h: CGFloat, vertical v: CGFloat) {
    self.init(top: v, leading: h, bottom: v, trailing: h)
  }
}

extension View {
  func padding(horizontal h: CGFloat, vertical v: CGFloat) -> some View {
    self.padding(EdgeInsets(horizontal: h, vertical: v)) 
  }
}

extension Color {
  init?(hexString: String) {
    var rgb: UInt64 = 0
    guard Scanner(string: hexString).scanHexInt64(&rgb) else {
      return nil
    }

    self.init(red: Double((rgb >> 16) & 0xff) / 255.0,
              green: Double((rgb >> 8) & 0xff) / 255.0,
              blue: Double((rgb) & 0xff) / 255.0)

  }
  
  static let primary = Color(hexString: "8CCBBE")!
  static let secondary = Color(hexString: "FCF876")!
  static let onPrimary = Color.white
  static let onSecondary = Color.black
  
  static let tertiary = Color(hexString: "3797A4")!
  
  static let tint = Color("Tint")
  static let lightBackground = Color("LightBackground")
  static let darkBackground = Color("DarkBackground")
  static let text = Color("Text")
  
  // MARK: Text Colors
  static let lightText = Color(UIColor.lightText)
  static let darkText = Color(UIColor.darkText)
  static let placeholderText = Color(UIColor.placeholderText)
  
  // MARK: Label Colors
  static let label = Color(UIColor.label)
  static let secondaryLabel = Color(UIColor.secondaryLabel)
  static let tertiaryLabel = Color(UIColor.tertiaryLabel)
  static let quaternaryLabel = Color(UIColor.quaternaryLabel)
  
  // MARK: Background Colors
  static let systemBackground = Color(UIColor.systemBackground)
  static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
  static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
  
  // MARK: Fill Colors
  static let systemFill = Color(UIColor.systemFill)
  static let secondarySystemFill = Color(UIColor.secondarySystemFill)
  static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
  static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
  
  // MARK: Grouped Background Colors
  static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
  static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
  static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
  
  // MARK: Gray Colors
  static let systemGray = Color(UIColor.systemGray)
  static let systemGray2 = Color(UIColor.systemGray2)
  static let systemGray3 = Color(UIColor.systemGray3)
  static let systemGray4 = Color(UIColor.systemGray4)
  static let systemGray5 = Color(UIColor.systemGray5)
  static let systemGray6 = Color(UIColor.systemGray6)
  
  // MARK: Other Colors
  static let separator = Color(UIColor.separator)
  static let opaqueSeparator = Color(UIColor.opaqueSeparator)
  static let link = Color(UIColor.link)
  
}
