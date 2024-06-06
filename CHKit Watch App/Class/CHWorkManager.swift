//
//  CHWorkManager.swift
//  CHKit Watch App
//
//  Created by evan on 2024/5/23.
//

import Foundation
import CoreBluetooth
import CryptoKit

/// 工作流管理类
class CHWorkManager: NSObject {
    // 特征值
    private var serviceCGM = "0000181f-0000-1000-8000-00805f9b34fb"
    private var characterAuthDev = "86805092-92b5-4d8c-9d73-0785ff6f9147"
    private var characterConvertCmd = "d78d0706-c775-448d-8a78-01215e7c2e11"
    private var characterGlucose = "2aa7"
    private var characterAuthFlag = "785022c6-08c0-48af-ad17-684bb889aa83"
    private var characterCurrentTime = "2a2b"
    private var characterAuthHost = "1756ef6e-884b-4eb0-b646-f04ab18408f9"
    private var characterGlucoseRecord = "69e4f45f-a180-422c-83c0-324146402112"
    private var characterRequestByCount = "ccecb015-6750-41fd-ba78-3fb77d350574"
    
    // BLE Info
    private var userInfo = CHUserInfo()
    private var bluetooth = CHBluetooth.instance
    private var peripheral: CBPeripheral?
    private var discoveredServices: Array<CBService> = []
    
    // 鉴权
    private var secretIndex = 0
    private var publicHexXStr = ""
    private var publicHexYStr = ""
    private var timeByte = Data()
    private var timeData = Data()
    private var randomIndex = 0
    /// AES加密
    private var aesSecretStr = ""
    
    /// ecc
    private lazy var ecc: SYEllipticCurveCrypto = {
        let ecc = SYEllipticCurveCrypto.generateKeyPair(for: SYEllipticCurveSecp256r1)
        ecc.decompressPublicKey(ecc.publicKey)
        return ecc
    }()
    
    override init() {
        super.init()
        settings()
    }
    
    private func settings() -> Void {
        bluetooth.onStateChange { central in
            print("蓝牙状态 \(central.state)")
        }
        // 发现外设
        bluetooth.onDiscoverPeripherals { [weak self] peripheral, advertisementData, rssi in
            guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, manufacturerData.count <= 2 else {
                return
            }
            let macData = manufacturerData.subdata(in: 2..<manufacturerData.count - 2)
            if self?.userInfo.mac == macData.hexString {
                self?.bluetooth.stopScan()
                self?.bluetooth.startConnect(peripheral)
            }
        }
        // 连接外设成功
        bluetooth.onConnectedPeripheral { [weak self] peripheral in
            self?.peripheral = peripheral
            self?.bluetooth.startDiscoverServices(peripheral)
        }
        // 连接失败
        bluetooth.onFailToConnect { peripheral, error in
            print("----- 蓝牙连接失败")
        }
        // 断开连接
        bluetooth.onDisconnect { peripheral, error in
            print("----- 断开蓝牙连接")
        }
        // 发现外设服务
        bluetooth.onDiscoverServices { [weak self] peripheral, error in
            print("------------------- 发现服务")
            self?.discoveredServices.append(contentsOf: peripheral.services ?? [])
            self?.bluetooth.startDiscoverCharacteristic(peripheral)
        }
        /// 找到特征值委托
        bluetooth.onDiscoverCharacteristics { [weak self] peripheral, service, error in
            self?.discoveredServices.removeLast()
            if (self?.discoveredServices.count ?? 0) > 0 {
                return
            }
            //鉴权
            if error == nil {
                self?.startAuth()
            }
        }
        
        // 读取特征值
        bluetooth.onReadValueForCharacteristic { [weak self] peripheral, characteristic, error in
            self?.readCharacteristic(characteristic: characteristic, error: error)
        }
        // 写入特征值
        bluetooth.onDidWriteValueForCharacteristic { [weak self] peripheral, characteristic, error in
            self?.writeCharacteristic(characteristic: characteristic, error: error)
        }
        
        let sancOption: Dictionary<String, Any> = [CBCentralManagerScanOptionAllowDuplicatesKey: false, CBCentralManagerOptionShowPowerAlertKey: true]
        bluetooth.optionsConfig(scanOptions: sancOption, scanServices: [CBUUID(string: serviceCGM)])
        
    }
    
    /// 开始鉴权
    private func startAuth() -> Void {
        guard let peripheral = peripheral, let characterAuthDev = getCharacteristic(characterAuthDev) else {
            return
        }
        bluetooth.readValue(peripheral, characterAuthDev)
    }
    
    /// 开始同步
    private func startSync(_ index: Int) -> Void {
        var count = 180,// 60*3
            start = index - count
        if index - count <= 60 {
            count = index - 60
            start = 61
        }
        let startData = start.toData(byteCount: 2)
        let countData = count.toData(byteCount: 2)
        let value = startData + countData
        guard let characterRequestByCount = getCharacteristic(characterRequestByCount), let peripheral = peripheral else {
            return
        }
        bluetooth.writeValue(value, peripheral, characterRequestByCount)
    }
    
    /// 血糖解析
    /// - Parameter characteristicValue: 血糖Info
    private func bloodGlucose(characteristicValue: Data) -> Void {
        
    }
    
}

extension CHWorkManager {
        
    private func readCharacteristic(characteristic: CBCharacteristic, error: Error?) -> Void {
        guard let peripheral = peripheral else {
            return
        }
        if characteristic.uuid == CBUUID(string: characterAuthDev) {
            guard let data = characteristic.value else {
                return
            }
            if data.count >= 36 {
                let indexdata = data.subdata(in: 0..<1)
                secretIndex = indexdata.hexString.hexToInt ?? 0
                timeData = data.subdata(in: 1..<3)
                let xData = data.subdata(in: 4..<32)
                let yData = data.subdata(in: 36..<(data.count - 36))
                publicHexXStr = xData.hexString
                publicHexYStr = yData.hexString
                guard let characterAuthFlag = getCharacteristic(characterAuthFlag) else {
                    return
                }
                bluetooth.readValue(peripheral, characterAuthFlag)
            }
        } else if characteristic.uuid == CBUUID(string: characterConvertCmd) {
            guard let data = characteristic.value else {
                return
            }
            let cmd = Int(data.hexString)
            if cmd == 3 {
                guard let characterGlucose = getCharacteristic(characterGlucose) else {
                    return
                }
                bluetooth.readValue(peripheral, characterGlucose)
            } else {
                
            }
        } else if characteristic.uuid == CBUUID(string: characterGlucose) {
            guard let glucoseRecord = getCharacteristic(characterGlucoseRecord) else {
                return
            }
            if glucoseRecord.isNotifying == false {
                bluetooth.notify(peripheral, glucoseRecord) { peripheral, characteristic, error in
                    print("---------------------- 历史数据")
                }
            }
            guard let characterGlucose = getCharacteristic(characterGlucose) else {
                return
            }
            if characterGlucose.isNotifying == false {
                bluetooth.notify(peripheral, characterGlucose) { peripheral, characteristic, error in
                    print("---------------------- 监听到新血糖")
                }
            }
            startSync(360)
        } else if characteristic.uuid == CBUUID(string: characterAuthFlag) {
            guard let data = characteristic.value else {
                return
            }
            if userInfo.authKeyArray.count > 0, userInfo.authKeyArray.count > secretIndex {
                guard let macData = userInfo.mac.hexToData,
                      let secretData = userInfo.authKeyArray[secretIndex].hexToData,
                      let xData = publicHexXStr.hexToData,
                      let yData = publicHexYStr.hexToData else {
                    return
                }
                let singData = secretData + macData + xData + yData + timeData
                let signHex = singData.sha256HexString
                if signHex == data.hexString {
                    guard let characterCurrentTime = getCharacteristic(characterCurrentTime) else {
                        return
                    }
                    bluetooth.readValue(peripheral, characterCurrentTime)
                }
            }
            
        } else if characteristic.uuid == CBUUID(string: characterCurrentTime) {
            guard let data = characteristic.value else {
                return
            }
            let timeStr = data.hexString(isLittle: true)
            let nextTime = (timeStr.hexToInt ?? 0) + 1
            randomIndex = Int(arc4random()) % userInfo.authKeyArray.count
            let indexHexStr = randomIndex.hexString
            guard let indexData = indexHexStr?.hexToData, let characterAuthHost = getCharacteristic(characterAuthHost) else {
                return
            }
            timeByte = nextTime.timeByte()
            let value = indexData + timeByte + ecc.publicKeyX + ecc.publicKeyY
            bluetooth.writeValue(value, peripheral, characterAuthHost)
        }
    }
    
    private func writeCharacteristic(characteristic: CBCharacteristic, error: Error?) -> Void {
        guard let peripheral = peripheral else {
            return
        }
        if characteristic.uuid == CBUUID(string: characterAuthHost) {
            if error != nil {
                return
            }
            let secretKeyStr = userInfo.authKeyArray[randomIndex]
            guard let macByte = userInfo.mac.hexToData,
                  let secretKeyData = secretKeyStr.hexToData else {
                return
            }
            let buildByteData = secretKeyData + macByte + ecc.publicKeyX + ecc.publicKeyY + timeByte
            let signData = Data(SHA256.hash(data: buildByteData))
            guard let characterAuthFlag = getCharacteristic(characterAuthFlag) else {
                return
            }
            bluetooth.writeValue(signData, peripheral, characterAuthFlag)
        } else if characteristic.uuid == CBUUID(string: characterAuthFlag) {
            if error != nil {
                return
            }
            //生成密钥, 并计算AES秘钥
            let publicCGMKey = ecc.getPublicKeyWith(x: publicHexXStr.hexToData!, y: publicHexYStr.hexToData!)
            let sharedSecretData = ecc.sharedSecret(forPublicKey: publicCGMKey)
            let sharedSecretStr = sharedSecretData.hexString
            var flag = false
            var index = 2
            while index < sharedSecretStr.count {
                let str = (sharedSecretStr as NSString).substring(with: NSMakeRange(index, 1))
                aesSecretStr = aesSecretStr + str
                if flag {
                    index += 1
                    flag = false
                } else {
                    index += 3
                    flag = true
                }
            }
            guard let characterConvertCmd = getCharacteristic(characterConvertCmd) else {
                return
            }
            bluetooth.readValue(peripheral, characterConvertCmd)
        }
    }
    
    private func getCharacteristic(_ uuid: String) -> CBCharacteristic? {
        guard let peripheral = peripheral else {
            return nil
        }
        for service in peripheral.services ?? [] {
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid == CBUUID(string: uuid) {
                    return characteristic
                }
            }
        }
        return nil
    }
    
}
