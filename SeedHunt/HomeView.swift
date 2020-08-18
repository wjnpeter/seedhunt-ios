//
//  ContentView.swift
//  SeedHunt
//
//  Created by Weijie Li on 4/6/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import CoreLocation

struct SeedFilter {
  var month: Int? // from 0
  var category: Seed.Category?
}

struct HomeView: View {
  @ObservedObject var viewModel = ViewModel()
  
  @State private var selectedSeed: Seed?
  
  @State private var showFilterView = false
  @State private var seedFilter = SeedFilter()
  
  @State private var showSearchView = false
  
  private var filterSeeds: [Seed] {
    guard let seeds = viewModel.seeds else { return [] }
    
    var ret = seeds
    if let filterMonth = seedFilter.month,
      let tempZone = viewModel.tempZone {
      ret = ret.filter { $0.months(for: tempZone).contains(filterMonth) }
    }
    
    if let filterCategory = seedFilter.category {
      ret = ret.filter { $0.category == filterCategory }
    }
    
    return ret
  }
  
  private var weatherIcon: UIImage {
    guard let icon = viewModel.weather?.current?.systemIcon else {
      return UIImage()
    }
    
    return UIImage(systemName: icon) ?? UIImage()
  }
  
  private var moonIcon: UIImage {
    guard let icon = viewModel.weather?.daily?.first?.moonIcon else {
      return UIImage()
    }
    
    return UIImage(named: icon) ?? UIImage()
  }
  
  var body: some View {
    
    return GeometryReader { geometry in
      NavigationView {
        VStack {
          List {
            ForEach(self.filterSeeds) { seed in
              NavigationLink(destination: SeedDetailView(selectedSeed: self.$selectedSeed, tempZone: self.viewModel.tempZone),
                             tag: seed,
                             selection: self.$selectedSeed) {
                SeedView(seed: seed)
              }
            }
          }
          
          HStack(alignment: .bottom) {
            NavigationLink(destination: CityDetailView(viewModel: self.viewModel)) {
              self.cityView(for: geometry.size)
            }
            
            Spacer()
            
            NavigationLink(destination: WeatherView(weather: self.viewModel.weather)) {
              self.trailingBottomView(for: geometry.size, icon: self.weatherIcon)
                .foregroundColor(Color.white)
            }
            
            NavigationLink(destination: MoonView(daily: self.viewModel.weather?.daily, moon: self.viewModel.moon)) {
              self.trailingBottomView(for: geometry.size, icon: self.moonIcon)
                .foregroundColor(Color.white)
            }
          }
        }
        .navigationBarTitle(Text("Seeds"))
        .navigationBarItems(leading: self.leadingBarItem(),
                            trailing: self.trailingBarItem())
        .sheet(isPresented: self.$showFilterView) {
          FilterView(seedFilter: self.$seedFilter, showFilterView: self.$showFilterView)
        }
      }
      .onAppear {
        self.viewModel.refetch()
      }
      .sheet(isPresented: self.$showSearchView) {
        // TODO, 合并FilterView的sheet
        SearchView(selection: self.$viewModel.location, showSearchView: self.$showSearchView)
      }

    }
  }
  
  // MARK: Views
  
  private func leadingBarItem() -> some View {
    Button(
      action: { self.showSearchView = true },
      label: {
        Image(systemName: "magnifyingglass")
      })
  }
  
  private func trailingBarItem() -> some View {
    Button(
      action: { self.showFilterView = true },
      label: {
        Text("Filter")
      })
  }
  
  private func cityView(for size: CGSize) -> some View {
    let radius = size.width / 4
    return ZStack {
      Circle()
        .frame(width: radius, height: radius)
        .foregroundColor(Color.blue)
      
      VStack {
        OptionalText(viewModel.location.name?.capitalized)
          .foregroundColor(Color.white)
        
        OptionalText(viewModel.koppenZone?.descript)
          .foregroundColor(Color.white)
      }
    }
  }
  
  private func trailingBottomView(for size: CGSize, icon: UIImage) -> some View {
    let radius = size.width / 6
    return ZStack {
      Circle()
        .frame(width: radius, height: radius)
        .foregroundColor(Color.blue)
      
      Image(uiImage: icon)
    }
  }
}

extension HomeView {
  struct SeedView: View {
    let seed: Seed
    
    var body: some View {
      GeometryReader { geometry in
        self.body(for: geometry.size)
      }
      .aspectRatio(16/9, contentMode: .fill)
    }
    
    private func body(for size: CGSize) -> some View {
      
      let infoWidth = size.width / 2.5
      let infoHeight = infoWidth
      
      return ZStack {
        OptionalURLImage(url: self.seed.wiki?.thumbnail)
          .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: size.width * 1.0 / 4.0))
        
        infoView
          .frame(width: infoWidth, height: infoHeight, alignment: .center)
          .offset(CGSize(width: infoWidth / 2, height: 0))
      }
      .background(Color.orange)
    }
    
    private var infoView: some View {
      ZStack {
        RoundedRectangle(cornerRadius: 4)
          .foregroundColor(Color.red)
        
        VStack {
          Text(seed.name)
          
          rateView
          
          HStack {
            planView
            Image(systemName: "chevron.right")
          }
        }
      }
    }
    
    private var rateView: some View {
      if seed.rate != nil {
        return Text("Rate: \(seed.rate!)")
      }
      
      return Text("")
    }
    
    private var planView: some View {
      HStack {
        if seed.maturity?.first != nil {
          Text("\(seed.maturity!.first!)")
          
          Text("Days to Maturity")
        } else if seed.germination?.first != nil {
          Text("\(seed.germination!.first!)")
          
          Text("Days to Germination")
        }
      }
      
    }
    
  }
}

