//
//  GameView.swift
//  ShakeApp
//
//  Created by 佐伯小遥 on 2025/06/29.
//

import AVFoundation
import SwiftUI

struct GameView: View {
    @StateObject private var shakeDetector = ShakeDetector()
    @State private var bubbleAudioPlayer: AVAudioPlayer!
    @State private var boomAudioPlayer: AVAudioPlayer!

    @State var currentText: String = "スタート！"
    @State var timer: Timer?
    @State var timeRemaining: Int = 30
    @State var score: Int = 0

    @State var isGameOver: Bool = false
    @State var waitingForShake: Bool = false
    @State var lastShakeCount: Int = 0

    // 食べ物の単語
    let foodWords: [String] = ["ペペロンチーノ", "ピータン", "モロヘイヤ"]
    // 食べ物ではない単語
    let nonFoodWords: [String] = ["ザッケローニ", "バルコニー", "クラリネット"]

    var body: some View {
        Group {
            if !isGameOver { // ゲーム中
                VStack(spacing: 30) {
                    Text("スコア: \(score)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    Text("残り時間: \(timeRemaining)秒")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)

                    Spacer()

                    Text(currentText)
                        .font(.system(size: 60, weight: .heavy, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding()
                        .frame(width: 300, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Spacer()

                    Text("表示された単語が「食べ物」ならシェイク！")
                        .font(.body)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                }
            } else {
                VStack(spacing: 40) {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                    Text("最終スコア: \(score)")
                        .font(.title)
                        .fontWeight(.semibold)
                    Button("もう一度") {
                        restartGame()
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 250, height: 70)
                    .background(Color.blue)
                    .clipShape(.rect(cornerRadius: 20))
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // 効果音の初期化
            bubbleAudioPlayer = try! AVAudioPlayer(data: NSDataAsset(name: "bubble")!.data)
            bubbleAudioPlayer.prepareToPlay()
            boomAudioPlayer = try! AVAudioPlayer(data: NSDataAsset(name: "boom")!.data)
            boomAudioPlayer.prepareToPlay()

            startGameTimer() // ゲーム開始タイマーを起動
        }
        .onChange(of: shakeDetector.shakeCount) {
            // シェイクが検出された時の処理
            // waitingForShake が true の時のみ判定
            if waitingForShake && shakeDetector.shakeCount > lastShakeCount {
                handleShake()
                lastShakeCount = shakeDetector.shakeCount
            }
        }
    }

    // 単語が食べ物かどうかを判定する関数
    func isFoodWord(_ word: String) -> Bool {
        return foodWords.contains(word)
    }

    // MARK: - ゲームロジック

    func startGameTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isGameOver {
                timeRemaining -= 1
                if timeRemaining <= 0 {
                    gameOver() // 時間切れ
                    return
                }

                waitingForShake = true // シェイク判定開始
                lastShakeCount = shakeDetector.shakeCount // 判定前のシェイク回数を保存

                // ランダムに食べ物と食べ物ではない単語を生成
                if Bool.random() { // 50%の確率で食べ物
                    currentText = foodWords.randomElement()!
                } else {
                    currentText = nonFoodWords.randomElement()!
                }
            }
        }
    }

    func handleShake() {
        // シェイクを検出したときの判定
        if isFoodWord(currentText) {
            score += 1
            bubbleAudioPlayer.currentTime = 0
            bubbleAudioPlayer.play()
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
            print("正解！スコア: \(score)")
        } else {
            print("不正解！シェイクすべきでなかった")
            gameOver()
        }
        waitingForShake = false // シェイク判定終了
    }

    func gameOver() {
        isGameOver = true
        timer?.invalidate() // タイマーを停止
        timer = nil
        boomAudioPlayer.currentTime = 0
        boomAudioPlayer.play()
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3){
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }

    func restartGame() {
        isGameOver = false
        score = 0
        timeRemaining = 30
        shakeDetector.shakeCount = 0
        lastShakeCount = 0
        currentText = "スタート！"
        timer?.invalidate() // 既存のタイマーを停止
        timer = nil
        startGameTimer() // 新しいゲームを開始
    }
}

#Preview {
    GameView()
}
