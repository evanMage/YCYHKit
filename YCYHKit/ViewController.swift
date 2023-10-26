//
//  ViewController.swift
//  YCYHKit
//
//  Created by evan on 2023/2/24.
//

import UIKit

class ViewController: UIViewController {
    
    let connecttivityManager = CHConnecttivityManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        connecttivityManager.activateWCSession()
    }

    @IBAction func send(_ sender: Any) {
        let data: Array<Double> = {
            var data: [Double] = []
            for _ in 0...50 {
                data.append(Double.random(in: 1...20))
            }
            return data
        }()
        let send = CHCoreInfo.send(data, "123")
        connecttivityManager.updateApplicationContext(send)
    }
    
}

