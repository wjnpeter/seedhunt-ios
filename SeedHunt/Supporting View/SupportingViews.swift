//
//  SupportingViews.swift
//  SeedHunt
//
//  Created by Weijie Li on 13/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct OptionalText: View {
  var content: String?
  
  init(_ content: String?) {
    self.content = content
  }
  
  init(_ content: Double?) {
    self.content = content == nil ? nil : String(content!)
  }
  
  var body: some View {
    Group {
      if content != nil {
        Text(content!)
      }
    }
  }
}

struct OptionalImage: View {
  var uiimage: UIImage?
  
  var body: some View {
    Group {
      if uiimage != nil {
        Image(uiImage: uiimage!)
      }
    }
  }
}

struct OptionalURLImage: View {
  var url: URL?
  
  @State private var img: UIImage?
  
  var body: some View {
    Image(uiImage: img ?? UIImage())
      .resizable()
      .aspectRatio(contentMode: .fit)
      .onAppear {
        self.fetchImg()
    }
  }
  
  private func fetchImg() {
    if img != nil { return }
    
    DispatchQueue.global().async {
      if let url = self.url,
        let data = try? Data(contentsOf: url) {
        DispatchQueue.main.async {
          self.img = UIImage(data: data)
        }
        
      }
    }
  }
}

