//
//  TrafficSnapshotStats.swift
//
//
//  Created by 黄城 on 2024/4/22.
//

import Foundation

public class TrafficSnapshotTracker: Codable {
  public typealias Connection = TrafficSnapshot.Connection
  
  var initialDownloadTotal: Int = 0
  var finalDownloadTotal: Int = 0
  var initialUploadTotal: Int = 0
  var finalUploadTotal: Int = 0
  var openConnections: Set<Connection>
  var closeConnections: Set<Connection>
  
  public var downloadTotal: Int { finalDownloadTotal - initialDownloadTotal }
  public var uploadTotal: Int { finalUploadTotal - initialUploadTotal }
  public lazy var wholeConnections: [Connection] = {
    var arr = Array(openConnections)
    arr.append(contentsOf: closeConnections)
    return arr
  }()
  
  public init(
    openConnections: [Connection] = [],
    closeConnections: [Connection] = []
  ) {
    self.openConnections = .init(openConnections)
    self.closeConnections = .init(closeConnections) 
  }
  
  public var openConnCount: Int {
    openConnections.count
  }
  
  public var closeConnCount: Int {
    closeConnections.count
  }
  
  @TrafficSnapshotActor
  public func update(with trafficSnapshot: TrafficSnapshot) {
    if initialDownloadTotal == 0, initialDownloadTotal != trafficSnapshot.downloadTotal {
      initialDownloadTotal = trafficSnapshot.downloadTotal
    }
    if initialUploadTotal == 0, initialUploadTotal != trafficSnapshot.uploadTotal {
      initialUploadTotal = trafficSnapshot.uploadTotal
    }
    
    finalDownloadTotal = trafficSnapshot.downloadTotal
    finalUploadTotal = trafficSnapshot.uploadTotal
    
    let connections = Set(trafficSnapshot.connections)
    
    // update closeConnections
    let closedConns = openConnections.subtracting(connections)
    for conn in closedConns {
      closeConnections.update(with: conn)
    }
    
    // update openConnections
    openConnections = connections
  }
}

@globalActor
struct TrafficSnapshotActor {
  actor ActorType { }

  static let shared: ActorType = ActorType()
}
