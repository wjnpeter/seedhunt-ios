//
//  Style.swift
//  SeedHunt
//
//  Created by Weijie Li on 19/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation
import UIKit

struct Style {
  
  static let spacing = Spacing()
  static let shape = Shape()
  
  static func style() {
    UITableView.appearance().tableFooterView = UIView()
  }
  
  struct Spacing {
    private var sizeClx: UIUserInterfaceSizeClass {
        return UIScreen.main.traitCollection.horizontalSizeClass
    }
    var siblings: CGFloat {
        return sizeClx == UIUserInterfaceSizeClass.regular ? 20.0 : 8.0
    }
    var superview: CGFloat  {
        return sizeClx == UIUserInterfaceSizeClass.regular ? 28.0 : 11.0
    }
  }
  
  struct Shape {
    var cornerRadius: CGFloat = 8
    var shadowRadius: CGFloat = 3
  }
}
