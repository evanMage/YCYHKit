//
//  ViewController.swift
//  YCYHKit
//
//  Created by evan on 2023/2/24.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    lazy var connecttivityManager = CHConnecttivityManager()
    lazy var healthKitManager = CHHealthKitManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let status = healthKitManager.authorizationStatus(.bloodGlucose)
        if status == .sharingDenied {
            debugPrint("未授权，请去“设置 - 隐私安全 - 健康”打开相关权限")
        }
        healthKitManager.requestHealthKitAuthorization(toShare: [HKQuantityType(.bloodGlucose)], read: [HKQuantityType(.stepCount), HKQuantityType(.distanceWalkingRunning)]) { success, error in
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
//        textField.resignFirstResponder()
//        guard let glucose = Double(textField.text ?? "") else {
//            return
//        }
//        healthKitManager.save(healthKitManager.bloodGlucose(date: Date(), bloodGlucose: glucose)) { success, error in
//            debugPrint("------ 写入 - \(success) \(error?.localizedDescription ?? "")")
//        }
        healthKitManager.readStepCount()
        
    }
}

extension ViewController: UITableViewDelegate {
    
}

