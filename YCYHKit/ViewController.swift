//
//  ViewController.swift
//  YCYHKit
//
//  Created by evan on 2023/2/24.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    lazy var connecttivityManager = CHConnecttivityManager()
    lazy var healthKitManager = CHHealthKitManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let status = healthKitManager.authorizationStatus(.bloodGlucose)
        if status == .notDetermined || status == .sharingDenied {
            debugPrint("未授权，请去“健康”打开权限")
        }
        healthKitManager.requestHealthKitAuthorization(toShare: [HKQuantityType(.bloodGlucose)], read: nil) { success, error in
            debugPrint("------权限--------- \(success) - \(error?.localizedDescription ?? "")")
        }
    }

    @IBAction func send(_ sender: Any) {
//        let data: Array<Double> = {
//            var data: [Double] = []
//            for _ in 0...50 {
//                data.append(Double.random(in: 0...20))
//            }
//            return data
//        }()
//        let send = CHCoreInfo.send(data, "123")
//        connecttivityManager.updateApplicationContext(send)
        let sample = healthKitManager.bloodGlucose(date: Date(), bloodGlucose: 11)
        healthKitManager.save(sample) { success, error in
            debugPrint("------ 写入 - \(success) \(error?.localizedDescription ?? "")")
        }
    }
}

