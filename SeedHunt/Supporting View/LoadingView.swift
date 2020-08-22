//
//  LoadingView.swift
//  SeedHunt
//
//  Created by Weijie Li on 19/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {
  
  @Binding var isLoading: Bool
  var content: () -> Content
  
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .center) {
        self.content()
          .disabled(self.isLoading)
          .blur(radius: self.isLoading ? 3 : 0)
        
        VStack {
          Text("Loading...")
          ActivityIndicator(isAnimating: .constant(true), style: .large)
        }
        .frame(width: geometry.size.width / 2,
               height: geometry.size.height / 5)
          .background(Color.secondary.colorInvert())
          .foregroundColor(Color.primary)
          .cornerRadius(20)
          .opacity(self.isLoading ? 1 : 0)
        
      }
    }
  }
  
}
