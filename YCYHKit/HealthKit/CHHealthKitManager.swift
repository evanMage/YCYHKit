//
//  CHHealthKitManager.swift
//  YCYHKit
//
//  Created by evan on 2024/1/24.
//

import Foundation
import HealthKit
import CoreLocation

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
    
    /// 检测权限授权
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
        healthStore.requestAuthorization(toShare: toShare, read: read) { success, error in
            completion(success, error)
        }
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
    public func delete(_ object: HKObject, withCompletion completion: @escaping (Bool, Error?) -> Void) -> Void {
        healthStore.delete(object, withCompletion: completion)
    }
    
    public func readStepCount() -> Void {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result else {
                print("Failed to fetch steps")
                return
            }
            
            let steps = result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0

            print("Steps: \(steps)")
        }
        
        healthStore.execute(query)
    }
    
    /// 读取具体健身数据
    /// - Parameter workoutActivityType: ActivityType
    /// - Parameter limit: 默认返回全部
    public func readSpecificWorkouts(_ workoutActivityType: HKWorkoutActivityType = .running, limit: Int = HKObjectQueryNoLimit, resultsHandler: @escaping (HKSampleQuery, [HKSample]?, (any Error)?) -> Void) -> Void {
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: workoutActivityType)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor], resultsHandler: resultsHandler)
        healthStore.execute(query)
    }
    
    /// 读取心率
    /// - Parameter workout: HKWorkout
    public func readHeartRateSamples(workout: HKWorkout, resultsHandler: @escaping (HKSampleQuery, [HKSample]?, (any Error)?) -> Void) -> Void {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor], resultsHandler: resultsHandler)
        healthStore.execute(query)
    }
    
    
    /// 读取路线
    /// - Parameter workout: HKWorkout
    public func readWorkoutRoute(workout: HKWorkout, resultsHandler: @escaping (HKSampleQuery, [HKSample]?, (any Error)?) -> Void) -> Void {
        let routeType = HKSeriesType.workoutRoute()
        let predicate = HKQuery.predicateForObjects(from: workout)
        let query = HKSampleQuery(sampleType: routeType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil, resultsHandler: resultsHandler)
        healthStore.execute(query)
    }
    
    /// 读取位置信息
    /// - Parameter route: HKWorkoutRoute 路线信息
    public func readLocations(route: HKWorkoutRoute, dataHandler: @escaping (HKWorkoutRouteQuery, [CLLocation]?, Bool, (any Error)?) -> Void) -> Void {
        let query = HKWorkoutRouteQuery(route: route, dataHandler: dataHandler)
        healthStore.execute(query)
    }
    
    /// 根据位置信息计算配速
    /// - Parameter locations: 位置信息
    public func calculatePacePerMinute(locations: [CLLocation]) -> Void {
        var previousLocation: CLLocation?
        var totalDistance: CLLocationDistance = 0.0
        var totalDuration: TimeInterval = 0.0
        var minuteDistance: CLLocationDistance = 0.0
        var minuteDuration: TimeInterval = 0.0

        for location in locations {
            if let previousLocation = previousLocation {
                let distance = location.distance(from: previousLocation)
                let duration = location.timestamp.timeIntervalSince(previousLocation.timestamp)
                totalDistance += distance
                totalDuration += duration
                minuteDistance += distance
                minuteDuration += duration

                if minuteDuration >= 60 {
                    let pace = minuteDistance / minuteDuration * 60
                    print("Pace: \(pace) meters/minute at \(location.timestamp)")
                    minuteDistance = 0
                    minuteDuration = 0
                }
            }
            previousLocation = location
        }
    }
}
