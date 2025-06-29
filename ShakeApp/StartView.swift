//
//  StartView.swift
//  ShakeApp
//
//  Created by 佐伯小遥 on 2025/06/29.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack{
            VStack(spacing: 40) {
                Text("シェイクゲーム")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("表示される単語が食べ物だったらスマホをシェイク！食べ物じゃなかったら、じっと我慢！")
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                NavigationLink(destination: GameView()){
                    Text("始める")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 250, height: 70)
                        .background(Color.blue)
                        .clipShape(.rect(cornerRadius: 20))
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    StartView()
}
