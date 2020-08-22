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
  
  @State private var showShareSheet: Bool = false
  @State private var isFavourite: Bool
  
  init(selectedSeed: Binding<Seed?>, tempZone: Zone?) {
    _selectedSeed = selectedSeed
    self.tempZone = tempZone
    
    _isFavourite = State(initialValue: selectedSeed.wrappedValue?.isFavourite() ?? false)
  }
  
  var body: some View {
    VStack {
      List {
        VStack(alignment: .leading) {
          rate
          OptionalURLImage(url: selectedSeed?.wiki?.thumbnail)
          actions
        }
        .buttonStyle(PlainButtonStyle())
        
        plan
        measure
        care
        
        VStack(alignment: .leading) {
          caption("Summary")
          OptionalText(selectedSeed?.wiki?.description)
        }
        
        Button(action: {}) {
          HStack {
            Text("Report an Issue")
            Spacer()
            Image(systemName: "exclamationmark.bubble")
          }
        }
      }
    }
    .navigationBarTitle(selectedSeed?.name ?? "")
    
  }
  
}

extension SeedDetailView {
  private var rate: some View {
    HStack {
      SeedRateView(rate: selectedSeed?.rate)
      
      OptionalText(selectedSeed?.rateDisplay())
        .foregroundColor(Color.gray)
    }
    .font(.callout)
  }
  
  private var favouriteAction: some View {
    Group {
      if self.selectedSeed != nil {
        action(icon: Image(systemName: isFavourite ? "heart.fill" : "heart"),
               label: "Favourite") {
                self.selectedSeed?.favourite()
                self.isFavourite.toggle()
        }
      }
    }
  }
  
  private var actions: some View {
    HStack {
//      action(icon: Image(systemName: "info.circle"), label: "Wiki") {
//      }
      
      favouriteAction
      
      action(icon: Image(systemName: "square.and.arrow.up"), label: "Share") { self.showShareSheet = true }
      .sheet(isPresented: $showShareSheet) {
        // TODO App Store link
        ShareSheet(activityItems: ["Check \(self.selectedSeed?.name ?? "") on SeedHunt - "])
      }
    }
  }
  
  private func action(icon: Image, label: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      VStack {
        icon
          .font(.title)
        
        Text(label)
          .font(.callout)
      }
      .padding(Style.spacing.superview)
    }
    .frame(maxWidth: .infinity)
    .background(Color(UIColor.systemGroupedBackground))
    .cornerRadius(Style.shape.cornerRadius)
    
  }
  
  private func caption(_ label: String) -> some View {
    Text(label)
      .font(.headline)
  }
  
  private func row(_ label: String, _ detail: String?) -> some View {
    HStack {
      if detail != nil {
        Text(label)
        Spacer()
        Text(detail!.capitalized)
      }
    }
    .font(.body)
  }
  
  private var plan: some View {
    VStack(alignment: .leading, spacing: 2) {
      caption("Plan")
      row("Sowing", selectedSeed?.monthsDisplay(for: tempZone))
      row("Germination", selectedSeed?.germination?.display(suffix: " Days"))
      row("Maturity", selectedSeed?.maturity?.display(suffix: " Days"))
    }
    .padding(.bottom, Style.spacing.superview)
  }
  
  private var measure: some View {
    VStack(alignment: .leading, spacing: 2) {
      caption("Measure")
      row("Sowing Depth", selectedSeed?.depth?.display(suffix: " mm"))
      row("Row Spacing", selectedSeed?.rowSpacing?.display(suffix: " cm"))
      row("Plant Spacing", selectedSeed?.spacing?.display(suffix: " cm"))
    }
    .padding(.bottom, Style.spacing.superview)
  }
  
  private var care: some View {
    VStack(alignment: .leading, spacing: 2) {
      caption("Care")
      row("Sow", selectedSeed?.sow?.joined(separator: ","))
      row("Frost", selectedSeed?.frost)
    }
    .padding(.bottom, Style.spacing.superview)
  }
}

struct SeedDetailView_Previews: PreviewProvider {
  static var previews: some View {
    var seed = Seed(name: "da bai cai")
    
    seed.category = .flower
    seed.rate = 3.5
    seed.germination = ClosedRange(uncheckedBounds: (10, 200))
    seed.maturity = ClosedRange(uncheckedBounds: (10, 200))
    seed.depth = ClosedRange(uncheckedBounds: (10, 200))
    seed.rowSpacing = ClosedRange(uncheckedBounds: (10, 200))
    seed.spacing = ClosedRange(uncheckedBounds: (10, 200))
    seed.sow = ["directly"]
    seed.frost = "hard"
    seed.wikiName = "hey wiki"
    
    let zone = Zone(code: 0, descript: "hot")
    
    return SeedDetailView(selectedSeed: .constant(seed), tempZone: zone)
  }
}
