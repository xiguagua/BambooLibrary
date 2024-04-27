//
//  TrafficSnapshot.swift
//  PacketTunnel
//
//  Created by 黄城 on 2024/4/17.
//

import Foundation

public struct TrafficSnapshot: Codable {
//  let id: UUID
  let downloadTotal: Int
  let uploadTotal: Int
  let connections: [Connection]
}


extension TrafficSnapshot {
// Demo:
//{
//  "id": "c2db2b45-f16c-461b-81ba-fc3d60dffe5e",
//  "metadata": {
//    "network": "udp",
//    "type": "Socks5",
//    "sourceIP": "127.0.0.1",
//    "destinationIP": "210.242.128.144",
//    "sourcePort": "59185",
//    "destinationPort": "443",
//    "host": "rr5---sn-ipoxu-umbk.googlevideo.com",
//    "dnsMode": "fake-ip",
//    "processPath": "",
//    "specialProxy": ""
//  },
//  "upload": 5428,
//  "download": 0,
//  "start": "2024-04-17T09:37:37.281549Z",
//  "chains": [
//    "🇨🇳 台湾标准 IEPL 中继 3",
//    "region.台湾",
//    "select.Youtube"
//  ],
//  "rule": "DomainSuffix",
//  "rulePayload": "googlevideo.com"
//}

  // MARK: - Connection
  public struct Connection: Codable {
    public let id: UUID
    let metadata: Metadata
    public var upload: Int = 0
    public var download: Int = 0 // byte
    let start: Date
    let chains: [String]
    // domain, domain-keyword, domain-suffix, match...
    let rule: String
    let rulePayload: String
    
    public var host: String {
      metadata.host
    }
    
    public var destinationIP: String {
      metadata.destinationIP
    }
    
    public var hostOrIP: String {
      if !metadata.host.isEmpty {
        metadata.host
      } else {
        metadata.destinationIP
      }
    }
    
    public var outbound: [String] {
      let reversedChains: [String] = chains.reversed()
      let max = min(2, reversedChains.count)
      
      return [String](reversedChains[0..<max])
//        .joined(separator: " > ")
    }
    
    enum CodingKeys: String, CodingKey {
      case id, metadata, upload, download, start
      case chains, rule, rulePayload
    }
    
    static private let formatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSSSSSZ"
      return formatter
    }()
    
    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: TrafficSnapshot.Connection.CodingKeys.self)
      
      self.id = try container.decode(UUID.self, forKey: TrafficSnapshot.Connection.CodingKeys.id)
      self.metadata = try container.decode(TrafficSnapshot.Metadata.self, forKey: TrafficSnapshot.Connection.CodingKeys.metadata)
      self.upload = try container.decode(Int.self, forKey: TrafficSnapshot.Connection.CodingKeys.upload)
      self.download = try container.decode(Int.self, forKey: TrafficSnapshot.Connection.CodingKeys.download)
    
      let _start = try container.decode(String.self, forKey: TrafficSnapshot.Connection.CodingKeys.start)
      self.start = Self.formatter.date(from: _start)!
//      self.start = try container.decode(Date.self, forKey: TrafficSnapshot.Connection.CodingKeys.start)
      
      self.chains = try container.decode([String].self, forKey: TrafficSnapshot.Connection.CodingKeys.chains)
      self.rule = try container.decode(String.self, forKey: TrafficSnapshot.Connection.CodingKeys.rule)
      self.rulePayload = try container.decode(String.self, forKey: TrafficSnapshot.Connection.CodingKeys.rulePayload)
    }
    
    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: TrafficSnapshot.Connection.CodingKeys.self)
      
      try container.encode(self.id, forKey: TrafficSnapshot.Connection.CodingKeys.id)
      try container.encode(self.metadata, forKey: TrafficSnapshot.Connection.CodingKeys.metadata)
      try container.encode(self.upload, forKey: TrafficSnapshot.Connection.CodingKeys.upload)
      try container.encode(self.download, forKey: TrafficSnapshot.Connection.CodingKeys.download)
      
      let _start = Self.formatter.string(from: self.start)
      try container.encode(_start, forKey: TrafficSnapshot.Connection.CodingKeys.start)
      
      try container.encode(self.chains, forKey: TrafficSnapshot.Connection.CodingKeys.chains)
      try container.encode(self.rule, forKey: TrafficSnapshot.Connection.CodingKeys.rule)
      try container.encode(self.rulePayload, forKey: TrafficSnapshot.Connection.CodingKeys.rulePayload)
    }
    
  }

  // MARK: - Metadata
  struct Metadata: Codable {
    // tcp, udp
    let network: String
    // http, socks5...
    let type: String
    let sourceIP, destinationIP: String
    let sourcePort, destinationPort: Int
    // target domain or ip
    let host: String
    // fake-ip...
    let dnsMode: String
    let processPath, specialProxy: String
    
    enum CodingKeys: String, CodingKey {
      case network, type, sourceIP, destinationIP
      case sourcePort, destinationPort
      case host, dnsMode, processPath, specialProxy
    }
    
    init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: TrafficSnapshot.Metadata.CodingKeys.self)
      
      self.network = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.network)
      self.type = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.type)
      self.sourceIP = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.sourceIP)
      
      self.destinationIP = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.destinationIP)
      let _sourcePort = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.sourcePort)
      self.sourcePort = Int(_sourcePort)!
      let _destinationPort = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.destinationPort)
      self.destinationPort = Int(_destinationPort)!
      
      self.host = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.host)
      self.dnsMode = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.dnsMode)
      self.processPath = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.processPath)
      self.specialProxy = try container.decode(String.self, forKey: TrafficSnapshot.Metadata.CodingKeys.specialProxy)
    }
    
    func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: TrafficSnapshot.Metadata.CodingKeys.self)
      try container.encode(self.network, forKey: TrafficSnapshot.Metadata.CodingKeys.network)
      try container.encode(self.type, forKey: TrafficSnapshot.Metadata.CodingKeys.type)
      try container.encode(self.sourceIP, forKey: TrafficSnapshot.Metadata.CodingKeys.sourceIP)
      try container.encode(self.destinationIP, forKey: TrafficSnapshot.Metadata.CodingKeys.destinationIP)
      
      let _sourcePort = String(self.sourcePort)
      try container.encode(_sourcePort, forKey: TrafficSnapshot.Metadata.CodingKeys.sourcePort)
      let _destinationPort = String(self.destinationPort)
      try container.encode(_destinationPort, forKey: TrafficSnapshot.Metadata.CodingKeys.destinationPort)
      
      try container.encode(self.host, forKey: TrafficSnapshot.Metadata.CodingKeys.host)
      try container.encode(self.dnsMode, forKey: TrafficSnapshot.Metadata.CodingKeys.dnsMode)
      try container.encode(self.processPath, forKey: TrafficSnapshot.Metadata.CodingKeys.processPath)
      try container.encode(self.specialProxy, forKey: TrafficSnapshot.Metadata.CodingKeys.specialProxy)
    }
  }
}

extension TrafficSnapshot.Connection: Hashable {
  public typealias Connection = Self
  
  public static func ==(lhs: Connection, rhs: Connection) -> Bool {
    lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
