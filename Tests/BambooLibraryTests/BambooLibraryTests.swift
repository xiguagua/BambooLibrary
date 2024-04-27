import XCTest
@testable import BambooLibrary

final class BambooLibraryTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
  
  func testDecodeFromConnection() throws {
    // Given
    let connectionJson = """
{
  "id": "c2db2b45-f16c-461b-81ba-fc3d60dffe5e",
  "metadata": {
    "network": "udp",
    "type": "Socks5",
    "sourceIP": "127.0.0.1",
    "destinationIP": "210.242.128.144",
    "sourcePort": "59185",
    "destinationPort": "443",
    "host": "rr5---sn-ipoxu-umbk.googlevideo.com",
    "dnsMode": "fake-ip",
    "processPath": "",
    "specialProxy": ""
  },
  "upload": 5428,
  "download": 0,
  "start": "2024-04-17T09:37:37.281549Z",
  "chains": [
    "🇨🇳 台湾标准 IEPL 中继 3",
    "region.台湾",
    "select.Youtube"
  ],
  "rule": "DomainSuffix",
  "rulePayload": "googlevideo.com"
}
"""
    let jsonDecoder = JSONDecoder()
    
    let connectionJsonData = Data(connectionJson.utf8)
    // When
    let connection = try jsonDecoder.decode(TrafficSnapshot.Connection.self, from: connectionJsonData)
    // Then
    XCTAssertNotNil(connection)
    XCTAssert(connection.id == UUID(uuidString: "c2db2b45-f16c-461b-81ba-fc3d60dffe5e"))
    XCTAssert(connection.upload == 5428)
  }
  
  
//  func testTrafficSnapshotTrackerCodable() throws {
//    let tracker = TrafficSnapshotTracker
//    tracker
//  }
}
