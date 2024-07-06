//
//  WiFiManager.swift
//  YCYHKit
//
//  Created by skraBgoDyhW on 2024/7/6.
//

import Foundation
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

class WiFiManager: NSObject {
    
    func wifiName() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    func contentWiFi(ssid: String, password: String, isWEP: Bool = false, completion: @escaping (Error?) -> Void) -> Void {
        let hotspotConfig = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: isWEP)
        NEHotspotConfigurationManager.shared.apply(hotspotConfig) { (error) in
            completion(error)
        }
    }
    
    func disconnectWiFi(ssid: String) -> Void {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
    }
    
}
