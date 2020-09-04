//
//  SafariView.swift
//  SeedHunt
//
//  Created by Weijie Li on 30/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import UIKit
import SafariServices

struct SafariView: UIViewControllerRepresentable {
  let url: URL!
  
  func makeUIViewController(context: Context) -> SFSafariViewController {
    return SFSafariViewController(url: url)
  }
  
  func updateUIViewController(_ uiViewController: SFSafariViewController,
                              context: UIViewControllerRepresentableContext<SafariView>) {
    
  }
}

