//
//  EpisodeList.swift
//  MovieDB
//
//  Created by allie on 28/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct EpisodeList: View {
    let store: Store<SeasonState, SeasonAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                switch viewStore.status {
                case .loading:
                    ProgressView()
                    
                case .error(let error):
                    ErrorTips(error: error)
                    
                case .normal:
                    ScrollView {
                        Text("\(viewStore.season?.name ?? "") \(viewStore.episodes.count) 集")
                            .font(.title2.weight(.medium))
                            .padding()
                        ForEach(viewStore.episodes) { episode in
                            EpisodeRow(episode: episode)
                        }
                    }
                }
            }
            .navigationTitle(viewStore.showName)
            .onAppear {
                viewStore.send(.fetchSeason)
            }
        }
    }
}

struct EpisodeRow: View {
    let episode: Episode

    var body: some View {
        HStack(spacing: 0) {
            URLImage(episode.stillPath?.imagePath(.best(w: 454, h: 254)) ?? "")
                .frame(width: 227, height: 127)
                .cornerRadius(6)
            
            VStack(alignment: .leading) {
                Text("\(episode.episodeNumber ?? 0) \(episode.name ?? "")")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Group {
                    Text(episode.airDate ?? "")
                    Text("\(episode.runtime ?? 0)m")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text(episode.overview ?? "")
                    .lineLimit(3)
            }
            .frame(maxHeight: 127)
            .padding(.horizontal)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical)
        .padding(.leading)
    }
}

struct EpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeList(store: .init(
            initialState: .init(tvID: 1, seasonNumber: 2, showName: "Show"),
            reducer: seasonReducer,
            environment: .init(mainQueue: .main, dbClient: .previews)
        ))
        .frame(minWidth: 730, minHeight: 300)
        
        EpisodeRow(episode: mockTVShows[0].seasons![0].episodes![0])
    }
}
