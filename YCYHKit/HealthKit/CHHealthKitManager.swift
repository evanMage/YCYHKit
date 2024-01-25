//
//  CHHealthKitManager.swift
//  YCYHKit
//
//  Created by evan on 2024/1/24.
//

import Foundation
import HealthKit

public class CHHealthKitManager: NSObject {
    
    lazy private var healthStore = HKHealthStore()
    
    //MARK: - private methods
    private func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    //MARK: - public methods
    /// 授权状态
    /// - Parameter identifier: HKQuantityTypeIdentifier
    /// - Returns: HKAuthorizationStatus
    public func authorizationStatus(_ identifier: HKQuantityTypeIdentifier) -> HKAuthorizationStatus {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else {
            return .notDetermined
        }
        return healthStore.authorizationStatus(for: type)
    }
    
    /// 请求授权
    /// - Parameters:
    ///   - toShare: 写入权限
    ///   - read: 读取权限
    ///   - completion: 结果
    /// - Returns: 无返回
    public func requestHealthKitAuthorization(toShare: Set<HKSampleType>?, read: Set<HKObjectType>?, completion: @escaping (Bool, Error?) -> Void) -> Void {
        if !isHealthDataAvailable() {
            completion(false, NSError(domain: "", code: -999, userInfo: [NSLocalizedDescriptionKey: "系统低于8.0，请升级系统"]))
            return
        }
        healthStore.requestAuthorization(toShare: toShare, read: read, completion: completion)
    }
    
    /// 生成血糖HKObject
    /// - Parameters:
    ///   - millimoles: millimoles
    ///   - date: 时间
    ///   - bloodGlucose: 血糖值
    /// - Returns: HKObject
    public func bloodGlucose(millimoles: Bool = true, date: Date, bloodGlucose: Double) -> HKObject {
        var unit = HKUnit.moleUnit(with: .milli, molarMass: HKUnitMolarMassBloodGlucose).unitDivided(by: HKUnit.liter())
        if !millimoles {
            unit = HKUnit(from: "mg/dL")
        }
        let quantity = HKQuantity(unit: unit, doubleValue: bloodGlucose)
        return HKQuantitySample(type: HKQuantityType(.bloodGlucose), quantity: quantity, start: date, end: date)
    }
    
    /// 写入数据到健康
    /// - Parameters:
    ///   - object: HKObject
    ///   - completion: 完成回调
    /// - Returns: 无返回
    public func save(_ object: HKObject, withCompletion completion: @escaping (Bool, Error?) -> Void) -> Void {
        healthStore.save(object, withCompletion: completion)
    }
    
    /// 删除数据
    /// - Parameters:
    ///   - object: HKObject
    ///   - completion: 完成回调
    /// - Returns: 无返回
    func delete(_ object: HKObject, withCompletion completion: @escaping (Bool, Error?) -> Void) -> Void {
        healthStore.delete(object, withCompletion: completion)
    }
}
