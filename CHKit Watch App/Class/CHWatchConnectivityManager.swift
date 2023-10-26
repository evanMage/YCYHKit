//
//  WatchConnectivityManager.swift
//
//  Created by evan on 2023/10/18.
//

import UIKit
import WatchConnectivity

class CHWatchConnectivityManager: NSObject, ObservableObject {
    
    override init() {
        super.init()
        WCSession.default.delegate = self
        activateWCSession()
    }
    
    func activateWCSession() -> Void {
        if WCSession.isSupported() {
            WCSession.default.activate()
        }
    }
    
    func sendToPhone(_ message: Dictionary<String, Any>) -> Void {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                debugPrint("发送信息错误: \(error.localizedDescription)")
            }
        } else {
            debugPrint("iPhone app is not reachable")
        }
    }
    
}

extension CHWatchConnectivityManager: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint("--------- 从手机接收信息： \(message)")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        debugPrint("---------- 后台接收信息： \(applicationContext)")
        DispatchQueue.main.async {
            CHCoreInfo.instance.coreInfo(applicationContext)
        }
    }
    
}
