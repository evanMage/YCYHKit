//
//  ExtensionMethod.swift
//  YCYHKit
//
//  Created by evan on 2024/5/15.
//

import Foundation
import CryptoKit
import CommonCrypto

extension String {
    
    /// MD5
    var md5: String {
        return Data(self.utf8).md5
    }
    
    /// 16进制字符串转Int
    var hexToInt: Int? {
        return Int(self, radix: 16)
    }
    
    /// 16进制字符串转成Data
    var hexToData: Data? {
        var hex = self
        if hex.hasPrefix("0x") {
            hex = String(hex.dropFirst(2))
        }
        guard hex.count % 2 == 0 else {
            return nil
        }
        var data = Data(capacity: hex.count / 2)
        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            if let byte = UInt8(hex[index..<nextIndex], radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        return data
    }
}

extension Data {
    /// MD5
    var md5: String {
        let hashed = Insecure.MD5.hash(data: self)
        let md5Str = hashed.map {
            String(format: "%02hhx", $0)
        }.joined()
        return md5Str
    }
    
    var hexString: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var sha256HexString: String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func hexString(isLittle: Bool = false) -> String {
        let hex = self.hexString
        var newHexArray: Array<String> = []
        for index in stride(from: 0, to: hex.count, by: 2) {
            let item = (hex as NSString).substring(with: NSRange(location: index, length: 2))
            newHexArray.append(item)
        }
        return newHexArray.reversed().joined()
    }
    
    // AES 加密
    func aesEncrypt(key: Data, iv: Data? = nil) -> Data? {
        return crypt(operation: CCOperation(kCCEncrypt), key: key, iv: iv)
    }
    
    // AES 解密
    func aesDecrypt(key: Data, iv: Data? = nil) -> Data? {
        return crypt(operation: CCOperation(kCCDecrypt), key: key, iv: iv)
    }
    
    private func crypt(operation: CCOperation, key: Data, iv: Data?) -> Data? {
        var outBytes = [UInt8](repeating: 0, count: self.count + kCCBlockSizeAES128)
        var numBytesCrypted: size_t = 0
        
        let options = CCOptions(kCCOptionPKCS7Padding)
        let cryptStatus = CCCrypt(
            operation,                  // 加密或解密
            CCAlgorithm(kCCAlgorithmAES128), // AES 算法
            options,                    // PKCS7Padding
            key.withUnsafeBytes { $0.baseAddress }, // 密钥
            kCCKeySizeAES256,           // 密钥长度
            iv?.withUnsafeBytes { $0.baseAddress },  // IV
            self.withUnsafeBytes { $0.baseAddress }, // 输入数据
            self.count,                 // 输入数据长度
            &outBytes,                  // 输出缓冲区
            outBytes.count,             // 输出缓冲区大小
            &numBytesCrypted            // 输出数据长度
        )
        
        if cryptStatus == CCCryptorStatus(kCCSuccess) {
            return Data(bytes: outBytes, count: numBytesCrypted)
        } else {
            return nil
        }
    }
    
}

extension Int {
    
    /// return hex string from int Value
    var hexString: String? {
        return String(self, radix: 16)
    }
    
    /// int 转 Data
    func toData(byteCount: Int = 8) -> Data {
        var data = Data()
        for index in 0..<byteCount {
            let byte = UInt8((self >> (index * 8)) & 0xff)
            let byteData = Data([byte])
            data.append(byteData)
        }
        return data
    }
    
    /// 蓝牙相关通信时间转data
    func timeByte() -> Data {
        let byte1 = UInt8(self & 0xff)
        let byte2 = UInt8((self >> 8) & 0xff)
        let byte3 = UInt8((self >> 16) & 0xff)
        let array = [byte3, byte1, byte2]
        return Data(array)
    }
    
}
