//
//  DetailOriginal.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {
    
    struct Original: View {
        let originalName: String
        let status: Movie.Status?
        let originalLanguage: String
        let budget: Int
        let revenue: Int
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                ForEach([
                    ("原产地片名", originalName),
                    ("状态", status?.rawValue ?? ""),
                    ("原始语言", originalLanguage),
                    ("预算", String(format: "$%d", locale: .current, budget)),
                    ("票房", String(format: "$%d", locale: .current, revenue))
                ], id: \.0) { item in
                    VStack(alignment: .leading) {
                        Text(item.0)
                            .font(.headline)
                        Text(item.1)
                    }
                }
            }
        }
    }
}

struct DetailFooter_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Original(
            originalName: mockMovies[0].originalTitle ?? "",
            status: .released,
            originalLanguage: mockMovies[0].originalLanguage ?? "",
            budget: mockMovies[0].budget ?? 0,
            revenue: mockMovies[0].revenue ?? 0
        )
    }
}
