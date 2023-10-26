//
//  CHConnecttivityManager.swift
//  CHConnecttivityManager
//
//  Created by evan on 2023/10/23.
//

import UIKit
import WatchConnectivity

class CHConnecttivityManager: NSObject {
    
    static let instance = CHConnecttivityManager()
    
    /// 收到信息回调
    var didReceive: ((Dictionary<String, Any>) -> Void)?
    
    override init() {
        super.init()
        WCSession.default.delegate = self
        activateWCSession()
    }
    
    public func activateWCSession() -> Void {
        if WCSession.isSupported() {
            WCSession.default.activate()
        }
    }
    
    /// 后台更新信息
    /// - Parameter info: 信息
    public func updateApplicationContext(_ info: Dictionary<String, Any>) -> Void {
        try? WCSession.default.updateApplicationContext(info)
    }
    
    /// 发送信息到iWatch
    /// - Parameter info: 发送信息
    public func sendToIWatch(_ info: Dictionary<String, Any>, errorHandler: ((String?) -> Void)? = nil) -> Void {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(info, replyHandler: nil) { error in
                errorHandler?(error.localizedDescription)
            }
        } else {
            errorHandler?("send error")
        }
    }
    
}

extension CHConnecttivityManager: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        didReceive?(message)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
