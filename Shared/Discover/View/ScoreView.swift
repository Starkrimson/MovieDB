//
//  ScoreView.swift
//  MovieDB
//
//  Created by allie on 15/7/2022.
//

import SwiftUI

struct ScoreView: View {
    let score: Double
    
    var body: some View {
        ZStack {
            // MARK: - 评分百分比
            Text("\(score * 10, specifier: "%.0f")%")
                .font(.caption)
                .frame(width: 34, height: 34)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(17)
            
            // MARK: - 圆环
            Circle()
                .trim(from: 1 - score / 10, to: 1)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 30/255.0, green: 213/255.0, blue: 169/255.0),
                            Color(red: 1/255.0, green: 180/255.0, blue: 228/255.0),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: .init(
                        lineWidth: 3, lineCap: .round, lineJoin: .round
                    )
                )
                .rotationEffect(.degrees(90))
                .rotation3DEffect(.degrees(180), axis: (1,0,0))
                .frame(width: 34, height: 34)
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(score: 6.6)
    }
}
