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
  
}
