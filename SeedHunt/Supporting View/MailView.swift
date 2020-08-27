//
//  MailView.swift
//  SeedHunt
//
//  Created by Weijie Li on 27/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {
  
  @Environment(\.presentationMode) var presentation
  @Binding var result: Result<MFMailComposeResult, Error>?
  
  init() {
    _result = Binding.constant(nil)
  }
  
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(presentation: presentation,
                       result: $result)
  }
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
    let vc = MFMailComposeViewController()
    vc.mailComposeDelegate = context.coordinator
    vc.setToRecipients(["wytheingz@gmail.com"])
    vc.setSubject("Report Issues")
    return vc
  }
  
  func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: UIViewControllerRepresentableContext<MailView>) {
    
  }
  
  
  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    
    @Binding var presentation: PresentationMode
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    init(presentation: Binding<PresentationMode>,
         result: Binding<Result<MFMailComposeResult, Error>?>) {
      _presentation = presentation
      _result = result
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
      defer {
        $presentation.wrappedValue.dismiss()
      }
      guard error == nil else {
        self.result = .failure(error!)
        return
      }
      self.result = .success(result)
    }
  }
}
