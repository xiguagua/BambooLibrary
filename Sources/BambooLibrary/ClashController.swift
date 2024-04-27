//
//  ClashController.swift
//  
//
//  Created by 黄城 on 2024/4/22.
//

import Foundation
import Alamofire


public final class ClashController {
  
//  public init() {
//    
//  }
  
  public static func getConnections() async -> TrafficSnapshot? {
    let url = "http://\(consts.localHost)/connections"
    let response = await AF.request(url, method: .get)
      .validate()
      .serializingDecodable(TrafficSnapshot.self)
      .response
    
    return response.value
  }
  
  public static func switchActiveProxy(name: String, _ parameters: [String: Any]) {
    #if targetEnvironment(simulator)
      return
    #else
      // command remote Clash Daemon
//      let consts = ClashController.consts
      let url = "http://\(consts.localHost)/proxies/\(name)"

      DispatchQueue.global().async {
        AF.request(
          url,
          method: .put,
          parameters: parameters,
          encoding: JSONEncoding.default
        )
        .validate()
        .response(completionHandler: { response in
          debugPrint("\(#function): \(response)")
        })
      }
    #endif
  }
  
  public static func reloadConfig(at path: String) {
    //    let headers: HTTPHeaders = [
    //      .authorization(bearerToken: "123456")
    //    ]
//    let consts = ClashController.consts
    let url = "http://\(consts.localHost)/configs"
    let parameters: [String: Any] = [
      "path": path,
    ]
    AF.request(
      url,
      method: .put,
      parameters: parameters,
      encoding: JSONEncoding.default
    )
    .validate()
    .response(completionHandler: { response in
      debugPrint("\(#function): \(response)")
    })
  }
}

public extension ClashController {
  static let consts = Constants()
  
  struct Constants {
    #if DEBUG
      #if os(tvOS)
        public let localHost = "192.168.1.104:19090" // tv wifi address
        public let externalController = "0.0.0.0:19090"
      #else
        // iOS wifi network 101
        public let localHost = "127.0.0.1:19090"
        public let externalController = "127.0.0.1:19090"
      #endif
    #else
      public let localHost = "127.0.0.1:19090"
      public let externalController = "127.0.0.1:19090"
    #endif
  }
}
