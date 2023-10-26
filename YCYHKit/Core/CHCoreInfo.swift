//
//  CHCoreInfo.swift
//  YCYHKit
//
//  Created by evan on 2023/10/26.
//

import UIKit

class CHCoreInfo: NSObject, ObservableObject {
    
    static let instance = CHCoreInfo()
    
    @Published var data: Array<Double> = []
    
    @Published var userInfo = ""
    
    func coreInfo(_ info: Dictionary<String, Any>) -> Void {
        data = info["data"] as? Array<Double> ?? []
        userInfo = info["userInfo"] as? String ?? ""
    }
    
    static func send(_ data: [Double], _ user: String) -> Dictionary<String, Any> {
        var info: Dictionary<String, Any> = Dictionary()
        info["data"] = data
        info["userInfo"] = user
        return info
    }
    
}
