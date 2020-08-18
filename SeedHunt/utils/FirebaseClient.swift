//
//  FirebaseClient.swift
//  SeedHunt
//
//  Created by Weijie Li on 11/8/20.
//  Copyright © 2020 WeiJie Li. All rights reserved.
//

import Foundation
import FirebaseFunctions

class FirebaseClient {
  static private var functions: Functions = {
    let ret = Functions.functions()
    ret.useFunctionsEmulator(origin: "http://localhost:5001")
    return ret
  }()
  
  static func call(fn: String, data: Any? = nil, completion: @escaping (HTTPSCallableResult?, Error?) -> Void) {
    functions.httpsCallable(fn).call(data, completion: completion)
    
  }
}
