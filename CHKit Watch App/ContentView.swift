//
//  ContentView.swift
//  CHKit Watch App
//
//  Created by evan on 2023/10/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var coreInfo = CHCoreInfo.instance
    @EnvironmentObject var watchConnectivityManager: CHWatchConnectivityManager

    var body: some View {
        VStack {
            if coreInfo.userInfo.isEmpty {
                Text("请登录手机端")
            } else {
                Button("发送") {
                    watchConnectivityManager.sendToPhone(["text": "123"])
                }
                .buttonStyle(.plain)
                CHLineChart(data: coreInfo.data, dataRange: [0, 20], size: CGSize(width: 180, height: 80), visualType: .outline(color: .blue, lineWidth: 2), showCricle: true)
                    .frame(width: 180, height: 80)
                    .border(.red)
            }
        }
//        .onAppear(perform: {
//            watchConnectivityManager.activateWCSession()
//        })
    }
}

#Preview {
    ContentView()
}
