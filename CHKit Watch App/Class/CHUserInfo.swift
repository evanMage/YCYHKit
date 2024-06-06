//
//  CHUserInfo.swift
//  CHKit Watch App
//
//  Created by evan on 2024/5/23.
//

import Foundation

class CHUserInfo: NSObject  {
    
    /// CGM Mac 地址
    var mac: String = ""
    /// 鉴权秘钥数组
    var authKeyArray: Array<String> = []
    var methodStr: String = ""
    var coefficientStr: String = ""
    var CGMActiveTime: Int64 = 0
    
}
