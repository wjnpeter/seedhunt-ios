//
//  ShareSheet.swift
//  SeedHunt
//
//  Created by Weijie Li on 20/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
  
  let activityItems: [Any]
  
  func makeUIViewController(context: Context) -> UIActivityViewController {
    let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    
    return activityViewController
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
  }
}
