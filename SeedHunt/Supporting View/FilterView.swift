//
//  FilterView.swift
//  SeedHunt
//
//  Created by Weijie Li on 14/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct FilterView: View {
  @Binding var seedFilter: SeedFilter
  @Binding var showFilterView: Bool
  @State private var draft: SeedFilter
  
  init(seedFilter: Binding<SeedFilter>, showFilterView: Binding<Bool>) {
    _seedFilter = seedFilter
    _showFilterView = showFilterView
    _draft = State(wrappedValue: seedFilter.wrappedValue)
  }
  
  var body: some View {
    NavigationView {
      Form {
        Picker("Month", selection: $draft.month) {
          Text("Any").tag(Int?.none)
          ForEach(Calendar.current.monthSymbols, id: \.self) { (monthSymbol: String?) in
            Text(monthSymbol!).tag(Calendar.current.monthSymbols.firstIndex(of: monthSymbol!))
          }
        }
        
        Picker("Category", selection: $draft.category) {
          Text("Any").tag(Seed.Category?.none)
          ForEach(Seed.Category.allCases, id: \.rawValue) { (category: Seed.Category?) in
            Text(category!.rawValue).tag(category)
          }
        }
        
        Section {
          Toggle(isOn: $draft.favouriteOnly) {
            Text("My Favourite Only")
          }
        }
        

        // not work:
        // ForEach(Seed.Category.allCases, id: \.self) { (category) in
        // work:
        // ForEach(Seed.Category.allCases, id: \.self) { (category: Seed.Category?) in
        // Picker selection 的类型要跟ForEach里面的一样，optional也要optional
      }
      .navigationBarTitle("Filter")
      .navigationBarItems(leading: cancel, trailing: done)
    }
  }
  
  private var cancel: some View {
    Button("Cancel") {
      self.showFilterView = false
    }
  }
  
  private var done: some View {
    Button("Done") {
      self.seedFilter = self.draft
      self.showFilterView = false
    }
  }
}


struct FilterView_Previews: PreviewProvider {
  static var previews: some View {
    FilterView(seedFilter: .constant(SeedFilter()), showFilterView: .constant(true))
  }
}
