//
//  ViewModel.swift
//  SeedHunt
//
//  Created by Weijie Li on 12/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import SwiftUI
import Combine
import MapKit

typealias Location = MKMapItem

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

  @Published private(set) var seeds: [Seed]?
  
  @Published private(set) var weather: Weather? {
    didSet {
      fetchMoon()
    }
  }
  @Published private(set) var moon: [Moon]?
  
  private var bomStns: [BOMProduct: BomStation] = [:]
  @Published private(set) var historicalWeathers: [BOMProduct: HistoricalWeather] = [:]
  @Published private(set) var agriculture = Agriculture()
  
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
  
  private var fetchCancellables = [AnyCancellable]()
  
  init() {
    if let locName =  UserDefaults.standard.string(forKey: Constants.locName) {
      let locLat =  UserDefaults.standard.double(forKey: Constants.locLat)
      let locLon =  UserDefaults.standard.double(forKey: Constants.locLon)
      location = Location.make(with: CLLocationCoordinate2DMake(locLat, locLon), name: locName)
    } else {
      location = LocationHelper.sydney
    }
  }
  
  func refetch() {
    fetchCancellables.forEach { $0.cancel() }
    
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
  }
  
  // MARK: fetch functions
  
  private func fetchAgriculture(product: BOMProduct) {
    guard let bomStn = bomStns[product] else { return }
    guard let geo = location.latLon() else { return }
    
    let request = fetchRequest(path: Agriculture.fetchPath, params: [
      "station": bomStn.id,
      "geo": geo
    ])
    
    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
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
    
    fetchCancellables.append(cancellable)
  }
  
  private func fetchHistoricalWeather(product: BOMProduct) {
    guard let bomStn = bomStns[product] else { return }
    
    let request = fetchRequest(path: HistoricalWeather.fetchPath, params: [
      "station": bomStn.id,
      "product": String(product.rawValue)
    ])
    
    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
      .map{ data, _ in
        let jsonObject = try? JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? [String: Any] else { return nil }

        return HistoricalWeather(json: json)
      }
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .assign(to: \.historicalWeathers[product], on: self)
    
    fetchCancellables.append(cancellable)
  }
  
  private func fetchBOMStation(product: BOMProduct, completion: @escaping (BomStation?) -> Void) {
    guard let geo = location.latLon() else { return }
    
    let request = fetchRequest(path: BomStation.fetchPath, params: [
      "geo": geo,
      "product": String(product.rawValue)
    ])
    
    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
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
    
    fetchCancellables.append(cancellable)
    
  }
  
  private func fetchMoon() {
    guard let moonPhases = weather?.daily?.compactMap({ $0.moonPhase }) else { return }
    
    FirebaseClient.call(fn: "actions", data: ["phases": moonPhases]) { (result, error) in
      if let moonActions = result?.data as? [[String]] {
        DispatchQueue.main.async {
          self.moon = []
          moonActions.forEach {
            self.moon?.append(Moon(action: $0))
          }
        }
        
      }
    }
  }
  
  private func fetchWeather() {
    guard let geo = location.latLon() else { return }
    
    let request = fetchRequest(path: Weather.fetchPath, params: [
      "geo": geo
    ])
    
    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
      .map { data, _ in
        let jsonObject = try? JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? [String: Any] else { return nil }

        return Weather(json: json)
      }
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .assign(to: \.weather, on: self)
    
    fetchCancellables.append(cancellable)
  }
  
  private func fetchZone(about: String) {
    guard let geo = location.latLon() else { return }
    
    let request = fetchRequest(path: Zone.fetchPath, params: [
      "about": about,
      "geo": geo
    ])
    
    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
      .map { data, _ in
        let jsonObject = try? JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? [String: Any] else { return nil }

        return Zone(json: json)
      }
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .assign(to: about == "koppenmajor" ? \.koppenZone : \.tempZone, on: self)
    
    fetchCancellables.append(cancellable)
  }
  
  private func fetchSeeds(tempZone: Int, month: Int? = nil, page: Int? = nil) {
    seeds = []
    
    let request = fetchRequest(path: Seed.fetchPath, params: [
      "tmpz": String(tempZone),
      "m": String(month ?? Calendar.current.component(.month, from: Date()) - 1),
      "page": String(page ?? 0)
    ])
    
    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
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
    
    fetchCancellables.append(cancellable)
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

