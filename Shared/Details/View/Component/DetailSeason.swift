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
            VStack {
                if let lastSeason = seasons.last {
                    HStack {
                        Text("CURRENT SEASON".localized)
                            .font(.title2.weight(.medium))
                        Text("\(lastSeason.name ?? "")")
                        Spacer()
                    }
                    .padding([.horizontal, .top])
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(seasons.reversed()) { season in
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
                                .frame(maxWidth: 300)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
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
        HStack {
            URLImage(profilePath.imagePath(.best(w: 260, h: 390)))
                .frame(width: 94, height: 141)
                .cornerRadius(6)

            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text(seasonName)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .fontWeight(.medium)
                HStack(spacing: 0) {
                    Text(airDate.string("yyyy"))
                    episodeCount.map { Text("｜\($0) \("EPISODES".localized)") }
                }
                Spacer()
                Text(overview)
                    .font(.subheadline)
            }
            .padding(.vertical, 6)
            .frame(maxHeight: 141)
            
            Spacer(minLength: 0)
        }
    }
}

struct DetailSeason_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Seasons(showName: "Show", tvID: 1, seasons: mockTVShows[0].seasons ?? [])
    }
}
