//
//  PropertyWrappers.swift
//  SeedHunt
//
//  Created by Weijie Li on 17/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation

@propertyWrapper
struct Once<ValueType> {
  
  init() {
    _value = nil
  }
  
  private var _value: ValueType?
  var wrappedValue: ValueType? {
    get { _value }
    set {
      if _value == nil {
        _value = newValue
      }
    }
  }
  
  var projectedValue: Any? {
    get { wrappedValue }
    set {
      if let newValue = newValue as? ValueType {
        wrappedValue = newValue
      }
    }
  }
  
}
