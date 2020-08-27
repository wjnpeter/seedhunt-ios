//
//  ContentView.swift
//  SeedHunt
//
//  Created by Weijie Li on 4/6/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import CoreLocation


struct HomeView: View {
  @ObservedObject var viewModel = ViewModel()
  
  @State private var selectedSeed: Seed?
  
  @State private var showFilterView = false
  
  @State private var showSearchView = false
  
  private var weatherIcon: Image {
    guard let icon = viewModel.weather?.current?.systemIcon else {
      return Image(uiImage: UIImage())
    }
    
    return Image(systemName: icon)
  }
  
  private var moonIcon: Image {
    guard let icon = viewModel.weather?.daily?.first?.moonIcon else {
      return Image(uiImage: UIImage())
    }
    
    return Image(icon)
      .renderingMode(.original)
      
  }
  
  var body: some View {
    
    return GeometryReader { geometry in
      
      NavigationView {
        ZStack {
          List {
            ForEach(self.viewModel.filterSeeds) { seed in
              ZStack {
                SeedView(seed: seed)
                
                NavigationLink(destination: SeedDetailView(selectedSeed: self.$selectedSeed,
                                                           tempZone: self.viewModel.tempZone),
                               tag: seed,
                               selection: self.$selectedSeed) {
                                EmptyView()
                }.buttonStyle(PlainButtonStyle())
              }
            }
          }

          // bottom
          VStack {
            Spacer()
            
            HStack(alignment: .bottom) {
              NavigationLink(destination: CityDetailView(viewModel: self._viewModel)) {
                self.cityView(for: geometry.size)
              }
              
              Spacer()
              
              NavigationLink(destination: WeatherView(weather: self.viewModel.weather)) {
                self.trailingBottomView(for: geometry.size, icon: self.weatherIcon)

              }
              
              NavigationLink(destination: MoonView(daily: self.viewModel.weather?.daily)) {
                HStack {
                self.trailingBottomView(for: geometry.size, icon: self.moonIcon)
                  // not show moon
                }
              }
            }
            .padding()
          }
        }
        .navigationBarTitle(Text("Seeds"))
        .navigationBarItems(leading: self.leadingBarItem(),
                            trailing: self.trailingBarItem())
        .sheet(isPresented: self.$showFilterView) {
          FilterView(seedFilter: self.$viewModel.seedFilter, showFilterView: self.$showFilterView)
        }
      }
      .onAppear {
        self.viewModel.refetch()
      }
      .sheet(isPresented: self.$showSearchView) {
        // TODO, 合并FilterView的sheet
        SearchView(selection: self.$viewModel.location,
                   seedFilter: self.$viewModel.seedFilter,
                   showSearchView: self.$showSearchView)
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
        .foregroundColor(Color.primary)
        .shadow()
      
      VStack {
        OptionalText(viewModel.location.name?.capitalized)
          .font(.headline)
          .lineLimit(nil)
        
        OptionalText(viewModel.koppenZone?.descript)
          .font(.footnote)
      }
      .foregroundColor(Color.onPrimary)
    }
  }
  
  private func trailingBottomView(for size: CGSize, icon: Image) -> some View {
    let radius = size.width / 6
    return ZStack {
      Circle()
        .frame(width: radius, height: radius)
        .foregroundColor(Color.primary)
        .shadow()
      
      icon
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: radius * 0.5)
        .foregroundColor(Color.onPrimary)
      
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
      .aspectRatio(4/3, contentMode: .fill)
    }
    
    private func body(for size: CGSize) -> some View {
      let imgWidth = size.width
      let imgHeight = size.height
      
      let infoWidth = size.width / 2
      let infoHeight = infoWidth * 3 / 4
      
      let offset = size.width * 1.0 / 4.0
      
      return ZStack {
        OptionalURLImage(url: self.seed.wiki?.thumbnail)
          .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: offset))
          .scaledToFill()
          .frame(width: imgWidth, height: imgHeight)
          .clipped()
          .shadow()
          .cornerRadius(Style.shape.cornerRadius)

        
        infoView
          .frame(width: infoWidth, height: infoHeight, alignment: .center)
          .offset(CGSize(width: offset, height: 0))
      }
    }
    
    private var infoView: some View {
      ZStack {
        RoundedRectangle(cornerRadius: Style.shape.cornerRadius)
          .foregroundColor(Color.white)
          .shadow()
        
        VStack(alignment: .leading) {
          Text(seed.name)
            .font(.headline)
          
          Spacer()
          
          VStack(alignment: .leading, spacing: 4) {
            OptionalText(seed.rateDisplay())
              .font(.footnote)
              .foregroundColor(Color.secondaryLabel)
            SeedRateView(rate: seed.rate)
              .font(.subheadline)
          }
          
          Spacer()
          
          HStack {
            planView
            Image(systemName: "chevron.right")
          }
        }
        .padding(horizontal: Style.spacing.siblings, vertical: Style.spacing.superview)
      }
    }
    
    private var planView: some View {
      HStack(alignment: .bottom, spacing: 1) {
        if seed.maturity?.first != nil {
          Text("\(seed.maturity!.first!)")
            .font(.subheadline)
            .bold()
          
          Text("Days to Maturity")
            .font(.footnote)
            .foregroundColor(Color.gray)
        } else if seed.germination?.first != nil {
          Text("\(seed.germination!.first!)")
            .font(.subheadline)
            .bold()
          
          Text("Days to Germination")
            .font(.footnote)
            .foregroundColor(Color.secondaryLabel)
        }
      }
      
    }
    
  }
}

extension View {
  func shadow() -> some View {
    shadow(color: Color.gray, radius: Style.shape.shadowRadius, y: 2)
  }
}
