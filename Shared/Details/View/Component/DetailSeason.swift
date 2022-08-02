//
//  DetailSeason.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import SwiftUI

extension DetailView {
    
    struct Seasons: View {
        let showName: String
        let tvID: Int
        let seasons: [Season]
        
        var body: some View {
            if let lastSeason = seasons.last {
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink(
                        destination: .episodeList(
                            showName: showName, tvID: tvID,
                            seasonNumber: lastSeason.seasonNumber ?? 0
                        )
                    ) {
                        HStack {
                            Text("当前季")
                                .font(.title2.weight(.medium))
                            Text("\(lastSeason.name ?? "")")
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    Text("\(lastSeason.airDate?.string("yyyy") ?? "") | \(lastSeason.episodeCount ?? 0)集")
                        .padding(.top, 3)
                    lastSeason.overview.map { overview in
                        Text(overview)
                            .padding(.top, 6)
                    }
                    NavigationLink(destination: .seasonList(showName: showName, tvID: tvID, seasons: seasons)) {
                        Text("查看全部季")
                            .font(.title3.weight(.medium))
                    }
                    .buttonStyle(.plain)
                    .padding(.top)
                }
                .padding()
            }
        }
    }
}

struct DetailSeason_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Seasons(showName: "Show", tvID: 1, seasons: mockTVShows[0].seasons ?? [])
    }
}
