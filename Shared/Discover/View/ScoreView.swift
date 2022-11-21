//
//  ScoreView.swift
//  MovieDB
//
//  Created by allie on 15/7/2022.
//

import SwiftUI

struct ScoreView: View {
    let score: Double
    var scoreOnly: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            if !scoreOnly {
                HStack(spacing: 0) {
                    ForEach(0..<fills, id: \.self) { _ in
                        Image(systemName: "star.fill")
                    }
                    if halfFills > 0 {
                        Image(systemName: "star.leadinghalf.filled")
                    }
                    ForEach(0..<stars, id: \.self) { _ in
                        Image(systemName: "star")
                    }
                }
            }
            Text("\(score, specifier: "%.1f")")
        }
        .font(.subheadline)
        .foregroundColor(score.scoreColor)
    }

    var fills: Int {
        Int(score * 0.5)
    }

    var halfFills: Int {
        score * 0.5 - floor(score * 0.5) >= 0.5 ? 1 : 0
    }

    var stars: Int {
        5 - fills - halfFills
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ScoreView(score: 7.6)
            ScoreView(score: 6.6)
            ScoreView(score: 3.6)
            ScoreView(score: 6.95, scoreOnly: true)
        }
    }
}
