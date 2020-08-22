//
//  Label.swift
//  SeedHunt
//
//  Created by Weijie Li on 22/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct Label: UIViewRepresentable {
  let text: String?
  let attributedText: NSAttributedString?
  
  init(_ text: String?) {
    self.text = text
    self.attributedText = nil
  }
  init(_ attributedText: NSAttributedString?) {
    self.text = nil
    self.attributedText = attributedText
  }
  
  func makeUIView(context: Context) -> UILabel {
    let ret = UILabel()
    ret.text = text
    ret.attributedText = attributedText
    return ret
  }
  
  func updateUIView(_ uiView: UILabel, context: Context) {
    
  }
}
