//
//  File.swift
//  
//
//  Created by 黄城 on 2024/4/21.
//

import Foundation

public enum AppMessage: Codable {
  case trafficSnapshot(isOn: Bool, countdown: Int)
  case respTrafficSnapshot(tracker: TrafficSnapshotTracker)
}
