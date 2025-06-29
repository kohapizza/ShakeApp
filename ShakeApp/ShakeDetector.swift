//
//  ShakeDetector.swift
//  shake-swiftui
//
//  Created by Kyoya Yamaguchi on 2025/05/29.
//

//
//  ShakeDetector.swift
//  shake-swiftui
//
//  Created by Kyoya Yamaguchi on 2025/05/29.
//

import Combine
import CoreMotion
import Foundation

class ShakeDetector: ObservableObject {
    @Published var shakeCount = 0 // シェイク回数

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    private let shakeThreshold: Double = 2.0 // シェイク判定の閾値（加速度の絶対値）

    init() {
        startAccelerometer()
    }

    private func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }

        motionManager.accelerometerUpdateInterval = 0.1 // 0.1秒ごとに加速度データを取得
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, _ in
            guard let self, let data else { return }

            let acceleration = data.acceleration
            // 任意の軸の加速度が閾値を超えたらシェイクと判定
            if fabs(acceleration.x) > self.shakeThreshold ||
               fabs(acceleration.y) > self.shakeThreshold ||
               fabs(acceleration.z) > self.shakeThreshold {
                DispatchQueue.main.async {
                    self.shakeCount += 1 // シェイク回数をインクリメント
                    print("Shake Detected! Count: \(self.shakeCount)") // デバッグ用
                }
            }
        }
    }

    deinit {
        motionManager.stopAccelerometerUpdates() // メモリ解放時に加速度計の更新を停止
    }
}
