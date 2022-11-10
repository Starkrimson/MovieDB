//
//  SeasonList.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import SwiftUI

struct SeasonList: View {
    let showName: String
    let tvID: Int
    let seasons: [Season]
    
    var body: some View {
        ScrollView {
            ForEach(seasons) { season in
                NavigationLink {
                    EpisodeList(store: .init(
                        initialState: .init(tvID: tvID, seasonNumber: season.seasonNumber ?? 0, showName: showName),
                        reducer: seasonReducer,
                        environment: .init(mainQueue: .main, dbClient: .live)
                    ))
                } label: {
                    SeasonRow(
                        showName: showName,
                        seasonName: season.name ?? "",
                        profilePath: season.posterPath ?? "",
                        airDate: season.airDate ?? .init(),
                        episodeCount: season.episodeCount ?? 0,
                        overview: season.overview ?? ""
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(showName)
    }
}

struct SeasonRow: View {
    let showName: String
    let seasonName: String
    let profilePath: String
    let airDate: Date
    let episodeCount: Int?
    let overview: String
    
    var body: some View {
        HStack(spacing: 0) {
            URLImage(profilePath.imagePath(.best(w: 260, h: 390)))
                .frame(width: 94, height: 141)
                .cornerRadius(6)

            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text(seasonName)
                        .font(.title2)
                    Text(airDate.string("yyyy"))
                        .padding(.leading, 6)
                    episodeCount.map { Text("｜\($0) 集") }
                }
                .fontWeight(.medium)
                Text("\(showName) \(seasonName) 于 \(airDate.string("yyyy", "MM", "dd")) 首播")
                Spacer()
                Text(overview)
                    .lineLimit(3)
            }
            .padding()
            .frame(maxHeight: 141)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical)
        .padding(.leading)
    }
}

struct SeasonList_Previews: PreviewProvider {
    static var previews: some View {
        SeasonList(
            showName: "Stranger Things",
            tvID: 10,
            seasons: mockTVShows[0].seasons ?? []
        )

        SeasonRow(
            showName: "Stranger Things",
            seasonName: "第1季",
            profilePath: "",
            airDate: Date(timeIntervalSinceReferenceDate: 100),
            episodeCount: 9,
            overview: "印第安纳州的霍金斯正在发生一些怪事，一名男孩突然失踪，拥有超自然能力的女孩意外出现。"
        )
    }
}
