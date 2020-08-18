//
//  ContentView.swift
//  SeedHunt
//
//  Created by Weijie Li on 4/6/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    ForEach(0..<2) { _ in
                        SeedView()
                    }
                    
                    HStack(alignment: .bottom) {
                        self.leadingBottomItem(for: geometry.size)
                        
                        Spacer()
                        
                        self.trailingBottomItem(for: geometry.size, title: "Weather")
                        self.trailingBottomItem(for: geometry.size, title: "Moon")
                    }
                }
                .navigationBarTitle(Text("Seeds"))
                .navigationBarItems(leading: self.leadingBarItem(), trailing: self.trailingBarItem())
            }
        
        }
    }
    
    // MARK: Views
    
    private func leadingBarItem() -> some View {
        Button(
            action: {},
            label: {
                Image(systemName: "magnifyingglass")
            })
    }
    
    private func trailingBarItem() -> some View {
        Button(
            action: {},
            label: {
                Text("Filter")
            })
    }
    
    private func leadingBottomItem(for size: CGSize) -> some View {
        let radius = size.width / 4
        return ZStack {
            Circle()
                .frame(width: radius, height: radius)
                .foregroundColor(Color.blue)

            VStack {
                Text("Bicheno")

                Text("Dry Zoom")
            }
        }
    }
    
    private func trailingBottomItem(for size: CGSize, title: String) -> some View {
        let radius = size.width / 6
        return ZStack {
            Circle()
                .frame(width: radius, height: radius)
                .foregroundColor(Color.blue)

            Text(title)
        }
    }
}

struct SeedView: View {
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
//            .aspectRatio(16/9, contentMode: .fill)
    }
    
    private func body(for size: CGSize) -> some View {
        
        let infoWidth = size.width / 2.5
        let infoHeight = infoWidth
        
        return ZStack {
            Image("seed1")
                .resizable()
                .aspectRatio(contentMode: .fit)

                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: size.width * 1.0 / 4.0))
            
            infoView()
                .frame(width: infoWidth, height: infoHeight, alignment: .center)
                .offset(CGSize(width: infoWidth / 2, height: 0))
        }
        .background(Color.orange)
    }
    
    private func infoView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(Color.red)
                
            VStack {
                Text("Tomato")
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
