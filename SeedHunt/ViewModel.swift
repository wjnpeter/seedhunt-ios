//
//  ViewModel.swift
//  SeedHunt
//
//  Created by Weijie Li on 12/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

class ViewModel: ObservableObject {
  @Published var location: Location {
    didSet {
      refetch()
      
      UserDefaults.standard.set(location.name, forKey: Constants.locName)
      UserDefaults.standard.set(location.latitude, forKey: Constants.locLat)
      UserDefaults.standard.set(location.longitude, forKey: Constants.locLon)
    }
  }
  
  @Published private(set) var tempZone: Zone? {
    didSet {
      if let code = tempZone?.code {
        fetchSeeds(tempZone: code)
      }
    }
  }
  @Published private(set) var koppenZone: Zone?

  @Published private var seeds: [Seed]?
  @Published var seedFilter = SeedFilter()
  var filterSeeds: [Seed] {
    guard let seeds = seeds else { return [] }
    
    var ret = seeds
    if let filterMonth = seedFilter.month,
      let tempZone = tempZone {
      ret = ret.filter { $0.months(for: tempZone).contains(filterMonth) }
    }
    
    if let filterCategory = seedFilter.category {
      ret = ret.filter { $0.category == filterCategory }
    }
    
    if seedFilter.favouriteOnly {
      ret = ret.filter { $0.isFavourite() }
    }
    
    return ret
  }
  
  @Published private(set) var weather: Weather? 
  
  private var bomStns: [BOMProduct: BomStation] = [:]
  @Published private(set) var historicalWeathers: [BOMProduct: HistoricalWeather] = [:]
  @Published private(set) var agriculture = Agriculture()
  
  private(set) var fetchTime = Date()
  
  func agriValue(for product: BOMProduct) -> Double? {
    switch product {
    case .terrTemperature:
      return agriculture.terrTemp
    case .evaporation:
      return agriculture.evaporation
    case .sunshine:
      return agriculture.sunshine
    default:
      return nil
    }
  }
  
  private var fetchCancellables = CancellableBag()
  
  init(location: Location? = nil) {
    if location == nil {
      self.location = LocationHelper.makeDefault()
    } else {
      self.location = location!
    }
    
  }
  
  func refetch() {
    fetchCancellables.cancelAll()
    
    fetchZone(about: "temperature")
    fetchZone(about: "koppenmajor")
    
    fetchWeather()
    
    // historical weather
    fetchBOMStation(product: BOMProduct.rainfallMonthly) { _ in
      self.fetchHistoricalWeather(product: BOMProduct.rainfallMonthly)
    }
    fetchBOMStation(product: BOMProduct.maxtemperatureMonthly) { _ in
      self.fetchHistoricalWeather(product: BOMProduct.maxtemperatureMonthly)
    }
    fetchBOMStation(product: BOMProduct.mintemperatureMonthly) { _ in
      self.fetchHistoricalWeather(product: BOMProduct.mintemperatureMonthly)
    }
    
    // agriculture
    fetchBOMStation(product: BOMProduct.terrTemperature) { _ in
      self.fetchAgriculture(product: BOMProduct.terrTemperature)
    }
    fetchBOMStation(product: BOMProduct.evaporation) { _ in
      self.fetchAgriculture(product: BOMProduct.evaporation)
    }
    fetchBOMStation(product: BOMProduct.sunshine) { _ in
      self.fetchAgriculture(product: BOMProduct.sunshine)
    }
    
    fetchTime = Date()
  }
  
  // MARK: fetch functions
  
  private func fetchAgriculture(product: BOMProduct) {
    guard let bomStn = bomStns[product] else { return }
    
    let request = fetchRequest(path: Agriculture.fetchPath, params: [
      "station": bomStn.id,
      "geo": location.latLon()
    ])
    
    URLSession.shared.dataTaskPublisher(for: request)
      .map{ data, _ in
        let jsonObject = try? JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? [String: Any] else { return [:] }

        return json
      }
      .replaceError(with: [:])
      .receive(on: DispatchQueue.main)
      .sink { json in
        self.agriculture.merge(from: json)
      }
      .store(in: &fetchCancellables)
  }
  
  private func fetchHistoricalWeather(product: BOMProduct) {
    guard let bomStn = bomStns[product] else { return }
    
    let request = fetchRequest(path: HistoricalWeather.fetchPath, params: [
      "station": bomStn.id,
      "product": String(product.rawValue)
    ])
    
    URLSession.shared.dataTaskPublisher(for: request)
      .map{ data, _ in
        let jsonObject = try? JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? [String: Any] else { return nil }

        return HistoricalWeather(json: json)
      }
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .assign(to: \.historicalWeathers[product], on: self)
      .store(in: &fetchCancellables)
    
  }
  
  private func fetchBOMStation(product: BOMProduct, completion: @escaping (BomStation?) -> Void) {
    
    let request = fetchRequest(path: BomStation.fetchPath, params: [
      "geo": location.latLon(),
      "product": String(product.rawValue)
    ])
    
    URLSession.shared.dataTaskPublisher(for: request)
      .map{ (data, _) -> BomStation? in
        let jsonObject = try? JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? [String: Any] else { return nil }

        return BomStation(json: json)
      }
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .sink { bomStn in
        self.bomStns[product] = bomStn

        completion(bomStn)
      }
      .store(in: &fetchCancellables)
    
  }
  
  private func fetchMoon() {
    guard let moonDailyPhases = weather?.daily?.compactMap({ $0.moonPhase }) else { return }
    
    // moon actions
    FirebaseClient.call(fn: "actions", data: ["phases": moonDailyPhases]) { (result, error) in
      if let moonActions = result?.data as? [[String]] {
        DispatchQueue.main.async {
          for (idx, actions) in moonActions.enumerated() {
            self.weather!.daily![idx].moonActions = actions
          }
          
        }
      }
    }
    
    // moon move
    let request = fetchRequest(path: Weather.fetchPathMoon, params: [
      "fcLength": String(moonDailyPhases.count)
    ])
    
    URLSession.shared.dataTaskPublisher(for: request)
      .map { data, _ in
        let jsonObject = try? JSONSerialization.jsonObject(with: data) 
        return jsonObject as? [String]
      }
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .sink { (moves: [String]?) in
        if let moves = moves {
          for (idx, move) in moves.enumerated() {
            self.weather!.daily![idx].moonMove = move
          }
        }
      }
      .store(in: &fetchCancellables)
      
  }
  
  private func fetchWeather() {
    let request = fetchRequest(path: Weather.fetchPath, params: [
      "geo": location.latLon()
    ])
    
    URLSession.shared.dataTaskPublisher(for: request)
      .map { data, _ in
        let jsonObject = try? JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? [String: Any] else { return nil }

        return Weather(json: json)
      }
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { (weather: Weather?) in
        self.weather = weather
        self.fetchMoon()
      })
      .store(in: &fetchCancellables)
  }
  
  func fetchZone(about: String) {
    
    let request = fetchRequest(path: Zone.fetchPath, params: [
      "about": about,
      "geo": location.latLon()
    ])
    
    URLSession.shared.dataTaskPublisher(for: request)
      .map { data, _ in
        let jsonObject = try? JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? [String: Any] else { return nil }

        return Zone(json: json)
      }
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .assign(to: about == "koppenmajor" ? \.koppenZone : \.tempZone, on: self)
      .store(in: &fetchCancellables)
  }
  
  private func fetchSeeds(tempZone: Int, month: Int? = nil, page: Int? = nil) {
    seeds = []
    
    let request = fetchRequest(path: Seed.fetchPath, params: [
      "tmpz": String(tempZone),
      "m": String(month ?? Calendar.current.component(.month, from: Date()) - 1),
      "page": String(page ?? 0)
    ])
    
    URLSession.shared.dataTaskPublisher(for: request)
      .map { data, _ in
        let jsonObject = try? JSONSerialization.jsonObject(with: data)
        let json = jsonObject as? [String: Any]
        
        // TODO
//        let pageCount = json?["pageCount"] as? Int
//        let plantTotal = json?["plantTotal"] as? Int
        guard let jsons = json?["data"] as? [[String: Any]] else { return nil }
        
        return jsons.compactMap { Seed(json: $0) }
    }
    .replaceError(with: nil)
    .receive(on: DispatchQueue.main)
    .assign(to: \.seeds, on: self)
    .store(in: &fetchCancellables)
  }
  
  private func fetchRequest(path: String, params: [String: String]) -> URLRequest {
    var url = URLComponents(string: Constants.serverBaseUrl + path)!
    url.queryItems = []
    params.forEach { k, v in
      url.queryItems?.append(URLQueryItem(name: k, value: v))
    }
    
    var request = URLRequest(url: url.url!)
    
    request.addValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiYWRtaW4iLCJpYXQiOjE1OTA1Mzg0NzN9.p4pkXkOyhPIvYDMVz3WnnsZ_gRRKQK8Grqt0wAHxc6k", forHTTPHeaderField: "Authorization")
    
    return request
  }
}

struct SeedFilter {
  var month: Int? // from 0
  var category: Seed.Category?
  var favouriteOnly = false
}
