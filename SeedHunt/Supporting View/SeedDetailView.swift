//
//  SeedDetailView.swift
//  SeedHunt
//
//  Created by Weijie Li on 13/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct SeedDetailView: View {
  @Binding var selectedSeed: Seed?
  let tempZone: Zone?
  
  var body: some View {
    List {
      VStack {
        HStack {
          OptionalText(selectedSeed?.name)
          closeButton
        }
        
        rate
        
        OptionalURLImage(url: selectedSeed?.wiki?.thumbnail)
        
        actions
      }
      
      VStack {
        Text("Plan")
        plan
      }
      
      VStack {
        Text("Measure")
        measure
      }
      
      VStack {
        Text("Care")
        care
      }
      
      VStack {
        Text("Summary")
        OptionalText(selectedSeed?.wiki?.description)
      }
      
      Button(action: {}) {
        HStack {
          Text("Report an Issue")
          Image(systemName: "exclamationmark.bubble")
        }
      }
    }
  }
  
  
}

extension SeedDetailView {
  private var rate: some View {
    Text("Rate...")
  }
  
  private var closeButton: some View {
    Button(action: {
      self.selectedSeed = nil
    }) {
      Image(systemName: "multiply.circle")
    }
  }
  
  private var actions: some View {
    HStack {
      Button(action: {}) {
        HStack {
          Image("wiki")
          Text("Wiki")
        }
      }
      
      Button(action: {}) {
        HStack {
          Image(systemName: "heart")
          Text("Favourite")
        }
      }
      
      Button(action: {
        
      }) {
        HStack {
          Image(systemName: "square.and.arrow.up")
          Text("Share")
        }
      }
    }
  }
  
  private var plan: some View {
    HStack {
      VStack {
        Text("Sowing")
        OptionalText(selectedSeed?.monthsDisplay(for: tempZone))
      }
      
      VStack {
        Text("Germination")
        OptionalText(selectedSeed?.germination?.display(suffix: " Days"))
      }
      
      VStack {
        Text("Maturity")
        OptionalText(selectedSeed?.maturity?.display(suffix: " Days"))
      }
    }
  }
  
  private var measure: some View {
    VStack {
      HStack {
        Text("Sowing Depth")
        OptionalText(selectedSeed?.depth?.display(suffix: " mm"))
      }
      
      HStack {
        Text("Row Spacing")
        OptionalText(selectedSeed?.rowSpacing?.display(suffix: " cm"))
      }
      
      HStack {
        Text("Plant Spacing")
        OptionalText(selectedSeed?.spacing?.display(suffix: " cm"))
      }
    }
  }
  
  private var care: some View {
    VStack {
      HStack {
        Text("Sow")
        OptionalText(selectedSeed?.sow?.description)
      }
      
      HStack {
        Text("Frost")
        OptionalText(selectedSeed?.frost)
      }
    }
  }
}
