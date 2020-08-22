//
//  SupportingViews.swift
//  SeedHunt
//
//  Created by Weijie Li on 13/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import Combine

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
  var name: String?
  var systemName: String?
  var uiImage: UIImage?
  
  var body: some View {
    Group {
      if uiImage != nil {
        Image(uiImage: uiImage!)
          .resizable()
      } else if systemName != nil {
        Image(systemName: systemName!)
      } else if name != nil {
        Image(name!)
      }
    }
  }
}

struct OptionalURLImage: View {
  var url: URL?
  
  @State private var img: UIImage?
  
  @State private var fetchCancellable = CancellableBag()
  
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
    guard let url = url else { return }
    
    fetchCancellable.cancelAll()
    URLSession.shared.dataTaskPublisher(for: url)
      .map({ data, _ in return UIImage(data: data) })
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .assign(to: \.img, on: self)
      .store(in: &fetchCancellable)

  }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
